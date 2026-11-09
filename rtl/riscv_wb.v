/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines a write-back module of risc-v cpu.
 *
 *******************************************************************************/

module riscv_wb (
    // Control signal
    input  wire         boutcome,   // I    1 Branch outcome
    input  wire         memtoreg,   // I    1 Register map WD3 select
    
    // Input data interface
    input  wire [31:0]  drdata,     // I   32 Read data from memory
    input  wire [31:0]  WD3_ap,     // I   32 Register write data (alures or pclus4)
    input  wire [31:0]  btarget,    // I   32 Branch target address
    input  wire [31:0]  pcplus4,    // I   32 Program counter plus 4
    
    // Output data interface
    output wire [31:0]  WD3_apr,    // O   32 Register write data (alures or pclus4 or read data from memory)
    output wire [31:0]  pc_nxt      // O   32 Program Counter next value
);

    /***************************************************************************
    * Combinational logic
    ****************************************************************************/

    assign WD3_apr = memtoreg ? drdata  : WD3_ap;
    assign pc_nxt  = boutcome ? btarget : pcplus4;

endmodule