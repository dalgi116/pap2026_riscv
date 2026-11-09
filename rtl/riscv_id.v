/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines an instruction decode module of risc-v cpu.
 *
 *******************************************************************************/

module riscv_id (
    // Clock, reset
    input  wire         clk,        // I    1 Clock
    input  wire         rst_n,      // I    1 Active-low reset

    // Instruction interface
    input  wire [31:0]  idata,      // I   32 Read instruction

    // Register write interface
    input  wire [4:0]   A3,         // I    5 Register write address
    input  wire [31:0]  WD3,        // I   32 Register write data
    input  wire         WE3,        // I    1 Register write enable

    // Data output interface
    output wire [4:0]   destreg,    // O    5 Destination register address
    output wire [31:0]  RD1,        // O   32 Register read port 1 data
    output wire [31:0]  RD2,        // O   32 Register read port 2 data
    output reg  [31:0]  immval,     // O   32 Immediate value

    // Control signals
    output wire         regwrite,   // O    1 Output Register map WE3
    output wire         memtoreg,   // O    1 Register map WD3 select
    output wire         memwrite,   // O    1 Data memory write enable
    output wire         memread,    // O    1 Data memory read enable
    output wire         bbxx,       // O    1 Branch if condition is met
    output wire         bjal,       // O    1 JAL instruction
    output wire         bjalr,      // O    1 JALR instruction
    output wire         bval,       // O    1 Branch condition if ALU result is zero
    output wire [2:0]   aluctrl,    // O    3 ALU control
    output wire         alusrc,     // O    1 ALU SrcB select
    output wire         auipc       // O    1 AUIPC instruction
);

    /***************************************************************************
    * Signal Declaration
    ****************************************************************************/

    // Instruction format encoding
    localparam FMT_I = 3'b000;  //  I-type
    localparam FMT_S = 3'b001;  //  S-type
    localparam FMT_B = 3'b010;  // SB-type
    localparam FMT_U = 3'b011;  //  U-type
    localparam FMT_J = 3'b100;  // UJ-type
    localparam FMT_R = 3'b101;  //  R-type

    // Register Map signals
    wire [4:0] A1;  // Register map read port 1 address
    wire [4:0] A2;  // Register map read port 2 address

    // Control signals
    wire [2:0]  format; // Instruction format

    /***************************************************************************
    * Combinational logic
    ****************************************************************************/

    // Register Map mapping
    assign A1 = idata[19:15];
    assign A2 = idata[24:20];
    
    // Destination register mapping
    assign destreg = idata[11:7];

    // Immediate value decoding
    always @(*) begin
        case (format)
            FMT_I: immval = {{20{idata[31]}}, idata[31:20]};
            FMT_S: immval = {{20{idata[31]}}, idata[31:25], idata[11:7]};
            FMT_B: immval = {{20{idata[31]}}, idata[7], idata[30:25], idata[11:8], 1'b0};
            FMT_U: immval = {idata[31:12], 12'b0};
            FMT_J: immval = {{12{idata[31]}}, idata[19:12], idata[20], idata[30:21], 1'b0};
            default: immval = 32'd0;
        endcase
    end

    /***************************************************************************
    * Submodule instantiation
    ****************************************************************************/

    // Register map
    reg_map u_reg_map (
        // Clock, reset
        .clk    (clk    ),  // I    1 Clock
        .rst_n  (rst_n  ),  // I    1 Acitve-low reset

        // Read interface
        .A1     (A1     ),  // I    5 Read port 1 address
        .A2     (A2     ),  // I    5 Read port 2 address
        .RD1    (RD1    ),  // O   32 Read port 1 data
        .RD2    (RD2    ),  // O   32 Read port 2 data
        
        // Write interface
        .A3     (A3     ),  // I    5 Write port 3 address
        .WD3    (WD3    ),  // I   32 Write port 3 data
        .WE3    (WE3    )   // I    1 Write port 3 enable
    );

    // Control unit
    ctrl_unit #(
        // Instruction format encoding
        .FMT_I      (FMT_I      ),  //  I-type
        .FMT_S      (FMT_S      ),  //  S-type
        .FMT_B      (FMT_B      ),  // SB-type
        .FMT_U      (FMT_U      ),  //  U-type
        .FMT_J      (FMT_J      ),  // UJ-type
        .FMT_R      (FMT_R      )   //  R-type
    ) u_ctrl_unit (
        // Input interface
        .idata      (idata      ),  // I   32 Read instruction
        
        // Output interface
        .regwrite   (regwrite   ),  // O    1 Register map WE3
        .memtoreg   (memtoreg   ),  // O    1 Register map WD3 select
        .memwrite   (memwrite   ),  // O    1 Data memory write enable
        .memread    (memread    ),  // O    1 Data memory read enable
        .bbxx       (bbxx       ),  // O    1 Branch if condition is met
        .bjal       (bjal       ),  // O    1 JAL instruction
        .bjalr      (bjalr      ),  // O    1 JALR instruction
        .bval       (bval       ),  // O    1 Branch condition if ALU result is zero
        .aluctrl    (aluctrl    ),  // O    3 ALU control
        .alusrc     (alusrc     ),  // O    1 ALU SrcB select
        .auipc      (auipc      ),  // O    1 AUIPC instruction
        .format     (format     )   // O    3 Instruction format
    );

endmodule