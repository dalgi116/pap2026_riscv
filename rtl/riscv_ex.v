/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines an execute module of risc-v cpu.
 *
 *******************************************************************************/

module riscv_ex (
    // Control signals
    input  wire [2:0]   aluctrl,    // I    3 ALU control
    input  wire         alusrc,     // I    1 ALU SrcB select
    input  wire         auipc,      // I    1 AUIPC instruction

    // Data input interface
    input  wire [31:0]  pc,         // I   32 Program Counter value
    input  wire [31:0]  RD1,        // I   32 Register read port 1 data
    input  wire [31:0]  RD2,        // I   32 Register read port 2 data
    input  wire [31:0]  immval,     // I   32 Immediate value

    // Data output interface
    output wire         aluzero,    // O    1 ALU result is zero
    output wire [31:0]  alures,     // O   32 ALU result
    output wire [31:0]  pcplusimm   // O   32 Program Counter plus immediate value
);

    /***************************************************************************
    * Signal Declaration
    ****************************************************************************/

    // ALU inputs
    wire [31:0] alusrcA;   // Source port A
    wire [31:0] alusrcB;   // Source port B

    /***************************************************************************
    * Combinational logic
    ****************************************************************************/

    // ALU inputs
    assign alusrcA = (auipc ) ? pc : RD1;
    assign alusrcB = (alusrc) ? immval : RD2;

    // Program Counter branch address
    assign pcplusimm = pc + immval;

    /***************************************************************************
    * Submodule instantiation
    ****************************************************************************/
    
    // ALU
    alu u_alu (
        // ALU interface
        .ctrl   (aluctrl),  // I    3 ALU control
        .srcA   (alusrcA),  // I   32 Source port A
        .srcB   (alusrcB),  // I   32 Source port B
        .res    (alures ),  // O   32 Result port
        .zero   (aluzero)   // O    1 Zero flag
    );

endmodule