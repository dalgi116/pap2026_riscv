/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines a top module of risc-v cpu.
 *
 *******************************************************************************/

module riscv (
    // Control signals
    input  wire         clk,    // I    1 Clock
    input  wire         rst_n,  // I    1 Acitve-low reset

    // Instrunction interface
    output wire [31:0]  iaddr,  // O   32 Instruction address
    input  wire [31:0]  idata,  // I   32 Read instruction

    // Data interface
    output wire [31:0]  daddr,  // O   32 Data address
    output wire [31:0]  dwdata, // O   32 Write data
    output wire         dwstrb, // O    1 Write strobe
    input  wire [31:0]  drdata, // I   32 Read data
    input  wire         dread   // I    1 Read strobe
);

    localparam PC_INIT_VAL = 32'h0000_0000; // Initial value of Program Counter

    /***************************************************************************
    * Signal Declaration
    ****************************************************************************/

    // Registers
    reg  [31:0] pc_reg; // Program Counter register

    // Intermediate signals
    wire [31:0] pcplus4;    // Program Counter plus 4
    wire [4:0]  destreg;    // Destination register address
    wire [31:0] RD1;        // Register read port 1 data
    wire [31:0] RD2;        // Register read port 2 data
    wire [31:0] immval;     // Immediate value
    wire        regwrite;   // Output Register map WE3
    wire        memtoreg;   // Register map WD3 select
    wire        memwrite;   // Data memory write enable
    wire        memread;    // Data memory read enable
    wire        bbxx;       // Branch if condition is met
    wire        bjal;       // JAL instruction
    wire        bjalr;      // JALR instruction
    wire        bval;       // Branch condition if ALU result is zero
    wire [2:0]  aluctrl;    // ALU control
    wire        alusrc;     // ALU SrcB select
    wire        auipc;      // AUIPC instruction
    wire        aluzero;    // ALU result is zero
    wire [31:0] alures;     // ALU result
    wire [31:0] pcplusimm;  // Program Counter plus immediate value
    wire        boutcome;   // Branch outcome
    wire [31:0] btarget;    // Branch target address
    wire [31:0] WD3_ap;     // Register write data (alures or pclus4)
    wire [31:0] WD3_apr;    // Register write data (alures or pclus4 or read data from memory)
    wire [31:0] pc_nxt;     // Program Counter next value


    /***************************************************************************
    * Combinational Logic
    ****************************************************************************/

    // Instruction interface
    assign iaddr  = pc_reg;

    // Data interface
    assign daddr  = alures;
    assign dwdata = RD2;
    assign dwstrb = memwrite;
    assign dread  = memread;

    /***************************************************************************
    * Sequential Logic
    ****************************************************************************/

    // Program Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= PC_INIT_VAL;
        end else begin
            pc_reg <= pc_nxt;
        end
    end    

    /***************************************************************************
    * Submodule Instantiation
    ****************************************************************************/

    // Instruction fetch
    riscv_if u_riscv_if (
        // Program Counter interface
        .pc         (pc_reg ),  // I   32 Program Counter
        .pcplus4    (pcplus4)   // O   32 Program counter plus 4
    );

    // Instruction decode
    riscv_id u_riscv_id (
        // Clock, reset
        .clk        (clk        ),  // I    1 Clock
        .rst_n      (rst_n      ),  // I    1 Active-low reset

        // Instruction interface
        .idata      (idata      ),  // I   32 Read instruction

        // Register write interface
        .A3         (destreg    ),  // I    5 Register write address
        .WD3        (WD3_apr    ),  // I   32 Register write data
        .WE3        (regwrite   ),  // I    1 Register write enable

        // Data output interface
        .destreg    (destreg    ),  // O    5 Destination register address
        .RD1        (RD1        ),  // O   32 Register read port 1 data
        .RD2        (RD2        ),  // O   32 Register read port 2 data
        .immval     (immval     ),  // O   32 Immediate value

        // Control signals
        .regwrite   (regwrite   ),  // O    1 Output Register map WE3
        .memtoreg   (memtoreg   ),  // O    1 Register map WD3 select
        .memwrite   (memwrite   ),  // O    1 Data memory write enable
        .memread    (memread    ),  // O    1 Data memory read enable
        .bbxx       (bbxx       ),  // O    1 Branch if condition is met
        .bjal       (bjal       ),  // O    1 JAL instruction
        .bjalr      (bjalr      ),  // O    1 JALR instruction
        .bval       (bval       ),  // O    1 Branch condition if ALU result is zero
        .aluctrl    (aluctrl    ),  // O    3 ALU control
        .alusrc     (alusrc     ),  // O    1 ALU SrcB select
        .auipc      (auipc      )   // O    1 JALR instruction address select
    );

    // Execute stage
    riscv_ex u_riscv_ex (
        // Control signals
        .aluctrl    (aluctrl    ),  // I    3 ALU control
        .alusrc     (alusrc     ),  // I    1 ALU SrcB select
        .auipc      (auipc      ),  // I    1 AUIPC instruction

        // Data input interface
        .pc         (pc_reg     ),  // I   32 Program Counter value
        .RD1        (RD1        ),  // I   32 Register read port 1 data
        .RD2        (RD2        ),  // I   32 Register read port 2 data
        .immval     (immval     ),  // I   32 Immediate value

        // Data output interface
        .aluzero    (aluzero    ),  // O    1 ALU result is zero
        .alures     (alures     ),  // O   32 ALU result
        .pcplusimm  (pcplusimm  )   // O   32 Program Counter plus immediate value
    );

    // Memory write/read stage
    riscv_mem u_riscv_mem (
        // Control signals
        .bbxx       (bbxx       ),  // I    1 Branch if condition is met
        .bjal       (bjal       ),  // I    1 JAL instruction
        .bjalr      (bjalr      ),  // I    1 JALR instruction
        .bval       (bval       ),  // I    1 Branch condition if ALU result is zero
        .aluzero    (aluzero    ),  // I    1 ALU result is zero

        // Data input interface
        .alures     (alures     ),  // I   32 ALU result
        .pcplusimm  (pcplusimm  ),  // I   32 Program Counter plus immediate value
        .pcplus4    (pcplus4    ),  // I   32 Program counter plus 4
        
        // Output interface
        .boutcome   (boutcome   ),  // O    1 Branch outcome
        .btarget    (btarget    ),  // O   32 Branch target address
        .WD3_ap     (WD3_ap     )   // O   32 Register write data (alures or pclus4)
    );

    // Write back stage
    riscv_wb u_riscv_wb (
        // Control signal
        .boutcome   (boutcome   ),  // I    1 Branch outcome
        .memtoreg   (memtoreg   ),  // I    1 Register map WD3 select
        
        // Input data interface
        .drdata     (drdata     ),  // I   32 Read data from memory
        .WD3_ap     (WD3_ap     ),  // I   32 Register write data (alures or pclus4)
        .btarget    (btarget    ),  // I   32 Branch target address
        .pcplus4    (pcplus4    ),  // I   32 Program counter plus 4
        
        // Output data interface
        .WD3_apr    (WD3_apr    ),  // O   32 Register write data (alures or pclus4 or read data from memory)
        .pc_nxt     (pc_nxt     )   // O   32 Program Counter next value
    );

endmodule
