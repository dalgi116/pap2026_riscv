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
    input  wire [31:0]  iaddr,  // I   32 Read instruction iaddress
    output wire [31:0]  idata   // O   32 Read instruction
);

    reg  [31:0] mem [0:MEM_DEPTH-1];    // Memory array
    
    assign idata = mem[iaddr[31:2]];

    // iaddress range check
    always @(*) begin
        if (iaddr >= MEM_DEPTH*4) begin
            $display("FAIL: Instruction iaddress %h out of range.", iaddr);
        end
    end

endmodule
