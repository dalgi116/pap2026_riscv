/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines an instruction fetch module of risc-v cpu. Communication
 *  with the instruction memory is done in the top module to avoid top module
 *  feed-through.
 *
 *******************************************************************************/

module riscv_if (
    // Program Counter interface
    input  wire [31:0]  pc,     // I   32 Program Counter
    output wire [31:0]  pcplus4 // O   32 Program counter plus 4
);

    assign pcplus4 = pc + 32'd4;

endmodule