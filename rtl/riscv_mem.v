/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines a memory module of risc-v cpu. Communication
 *  with the data memory is done in the top module to avoid top module
 *  feed-through.
 *
 *******************************************************************************/

module riscv_mem (
    // Control signals
    input  wire         bbxx,       // I    1 Branch if condition is met
    input  wire         bjal,       // I    1 JAL instruction
    input  wire         bjalr,      // I    1 JALR instruction
    input  wire         bval,       // I    1 Branch condition if ALU result is zero
    input  wire         aluzero,    // I    1 ALU result is zero

    // Data input interface
    input  wire [31:0]  alures,     // I   32 ALU result
    input  wire [31:0]  pcplusimm,  // I   32 Program Counter plus immediate value
    input  wire [31:0]  pcplus4,    // I   32 Program counter plus 4
    
    // Output interface
    output wire         boutcome,   // O    1 Branch outcome
    output wire [31:0]  btarget,    // O   32 Branch target address
    output wire [31:0]  WD3_ap      // O   32 Register write data (alures or pclus4)
);

    /***************************************************************************
    * Signal Declaration
    ****************************************************************************/

    wire wd3_sel;   // Register map WD3 select

    /***************************************************************************
    * Combinational logic
    ****************************************************************************/

    // Control signals
    assign wd3_sel = bjal || bjalr;
    assign boutcome = ((!bval ^^ aluzero) && bbxx) || wd3_sel;

    // Output data
    assign btarget = (bjalr  ) ? {alures[31:1], 1'b0} : pcplusimm;
    assign WD3_ap  = (wd3_sel) ? pcplus4 : alures;

endmodule