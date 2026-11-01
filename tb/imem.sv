/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines a 0-cycle delay ROM model used for risc-v verification.
 *  The memory must be initialized from the top module.
 *
 *******************************************************************************/

module imem # (
    parameter MEM_DEPTH = 8192  // Memory depth
) ( 
    // Memory interface
    input  wire [31:0]  addr,   // I   32 Read instruction address
    output wire [31:0]  rins    // O   32 Read instruction
);

    reg  [31:0]   mem     [0:MEM_DEPTH-1];    // Memory array
    
    assign rins = mem[addr[31:2]];

    // Address range check
    always @(*) begin
        if (addr >= MEM_DEPTH*4) begin
            $display("FAIL: Instruction address out of range");
        end
    end

endmodule
