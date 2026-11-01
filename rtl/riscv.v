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
    input  wire         clk,        // I    1 Rising-edge active system clock
    input  wire         rst_n,      // I    1 Active-low system reset

    // Instrunction interface
    output wire [31:0]  iaddr,      // O   32 Instruction address
    input  wire [31:0]  iread,      // I   32 Read instruction

    // Data interface
    output wire [31:0]  daddr,      // O   32 Read/Write data address
    input  wire [31:0]  dread,      // I   32 Read data
    output wire [31:0]  dwrite,     // O   32 Write data
    output wire         dwren       // O    1 Data write enable
);

    localparam PC_INIT_VAL = 32'h0000_0000;     // Initial value of Program Counter

/*******************************************************************************
* Signal Declaration
********************************************************************************/

    // Program Counter signals
    reg  [31:0]     pc;             // Program Counter register
    wire [31:0]     pcplus4;        // Program Counter incremented by 4
    wire [31:0]     pcbranch;       // Program Counter branch
    wire [31:0]     pcnext;         // Next Program Counter value

    // Register Map
    wire [4:0]      rm_a1;          // Port 1 address
    wire [4:0]      rm_a2;          // Port 2 address
    wire [4:0]      rm_a3;          // Port 3 address
    wire [31:0]     rm_rd1;         // Port 1 read data
    wire [31:0]     rm_rd2;         // Port 2 read data
    wire [31:0]     rm_wd3;         // Port 3 write data

    // ALU
    wire [31:0]     alu_srcA;       // Source port A
    wire [31:0]     alu_srcB;       // Source port B
    wire [31:0]     alu_res;        // Result port
    wire            alu_zero;       // Zero flag

    // Control Unit
    wire [6:0]      cr_opcode;      // Operation code
    wire [2:0]      cr_funct3;      // Function code 3
    wire [6:0]      cr_funct7;      // Function code 7
    wire            cr_pcsrc;       // Instruction address select
    wire            cr_pcsrc_jalr;  // JALR instruction address select
    wire            cr_mem2reg;     // Register map WD3 select
    wire            cr_alusrc;      // ALU SrcB select
    wire            cr_regwrite;    // Register map WE3
    wire            cr_memwrite;    // Data memory write enable
    wire [2:0]      cr_immsrc;      // Immediate source select
    wire [2:0]      cr_aluctrl;     // ALU control vector

    reg  [31:0]     imm_val;        // Immediate value
    wire            is_auipc;       // AUIPC instruction flag

/*******************************************************************************
* Combinational Logic
********************************************************************************/
    
    // Immediate value generation
    always @(*) begin
        case (cr_immsrc)
            3'b000: imm_val = {{20{iread[31]}}, iread[31:20]};                                  // I-type
            3'b001: imm_val = {{20{iread[31]}}, iread[31:25], iread[11:7]};                     // S-type
            3'b010: imm_val = {{20{iread[31]}}, iread[7], iread[30:25], iread[11:8], 1'b0};     // B-type
            3'b011: imm_val = {iread[31:12], 12'b0};                                            // U-type
            3'b100: imm_val = {{12{iread[31]}}, iread[19:12], iread[20], iread[30:21], 1'b0};   // J-type
            default: imm_val = 32'd0;
        endcase
    end

    // Program Counter logic
    assign pcplus4  = pc + 32'd4;
    assign pcbranch = pc + imm_val;
    assign pcnext = cr_pcsrc_jalr ? (rm_rd1 + imm_val) : (cr_pcsrc ? pcbranch : pcplus4);

    // Instruction decode
    assign cr_opcode = iread[6:0];
    assign cr_funct3 = iread[14:12];
    assign cr_funct7 = iread[31:25];

    // Register Map mapping
    assign rm_a1  = iread[19:15];
    assign rm_a2  = iread[24:20];
    assign rm_a3  = iread[11:7];
    
    // Write data mux (JAL/JALR save PC+4)
    assign rm_wd3 = (cr_pcsrc | cr_pcsrc_jalr) ? pcplus4 : (cr_mem2reg ? dread : alu_res);

    // ALU mux
    assign is_auipc = (cr_opcode == 7'b0010111);
    assign alu_srcA = is_auipc ? pc : rm_rd1;
    assign alu_srcB = cr_alusrc ? imm_val : rm_rd2;

    // External Assignments
    assign iaddr  = pc;
    assign daddr  = alu_res;
    assign dwrite = rm_rd2;
    assign dwren  = cr_memwrite;

/*******************************************************************************
* Sequential Logic
********************************************************************************/

    // Program Counter Assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= PC_INIT_VAL;
        end else begin
            pc <= pcnext;
        end
    end

/*******************************************************************************
* Submodule Instantiation
********************************************************************************/

    reg_map u_reg_map (
        // Clock, reset
        .clk        (clk        ),  // I    1 Rising-edge active system clock
        .rst_n      (rst_n      ),  // I    1 Active-low system reset

        // Data interface
        .A1         (rm_a1      ),  // I    5 Port 1 address
        .A2         (rm_a2      ),  // I    5 Port 2 address
        .A3         (rm_a3      ),  // I    5 Port 3 address
        .RD1        (rm_rd1     ),  // O   32 Port 1 read data
        .RD2        (rm_rd2     ),  // O   32 Port 2 read data
        .WD3        (rm_wd3     ),  // I   32 Port 3 write data
        .WE3        (cr_regwrite)   // I    1 Port 3 write enable
    );

    alu u_alu (
        // ALU interface
        .ctrl       (cr_aluctrl ),  // I    3 Control vector
        .srcA       (alu_srcA   ),  // I   32 Source port A
        .srcB       (alu_srcB   ),  // I   32 Source port B
        .res        (alu_res    ),  // O   32 Result port
        .zero       (alu_zero   )   // O    1 Zero flag
    );

    ctrl_unit u_ctrl_unit (
        // Input interface
        .opcode     (cr_opcode      ),  // I    7 Operation code
        .funct3     (cr_funct3      ),  // I    3 Function code 3
        .funct7     (cr_funct7      ),  // I    7 Function code 7
        .aluzero    (alu_zero       ),  // I    1 ALU zero flag
        
        // Output interface
        .pcsrc      (cr_pcsrc       ),  // O    1 Instruction address select
        .pcsrc_jalr (cr_pcsrc_jalr  ),  // O    1 JALR instruction address select
        .mem2reg    (cr_mem2reg     ),  // O    1 Register map WD3 select
        .alusrc     (cr_alusrc      ),  // O    1 ALU SrcB select
        .regwrite   (cr_regwrite    ),  // O    1 Register map WE3
        .memwrite   (cr_memwrite    ),  // O    1 Data memory write enable
        .immsrc     (cr_immsrc      ),  // O    3 Immediate source select
        .aluctrl    (cr_aluctrl     )   // O    3 Combinational ALU control vector
    );

endmodule
