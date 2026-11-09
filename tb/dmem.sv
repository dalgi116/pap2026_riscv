/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines a RAM model used for risc-v verification. The memory must
 *  be initialized from the top module.
 *
 *******************************************************************************/

module dmem # (
    parameter MEM_DEPTH = 8192  // Memory depth
) (
    // Clock, reset
    input  wire         clk,    // I    1 Clock
    input  wire         rst_n,  // I    1 Acitve-low reset
    
    // Data interface
    input  wire [31:0]  daddr,  // I   32 Address
    input  wire [31:0]  dwdata, // I   32 Write data
    input  wire         dwstrb, // I    1 Write enable
    output wire [31:0]  drdata, // O   32 Read data
    input  wire         dread   // I    1 Write strobe
);

    reg  [31:0] mem [0:MEM_DEPTH-1];    // Memory array
    
    assign drdata = mem[daddr[31:2]];

    // Address range check
    always @(*) begin
        if (dwstrb && (daddr >= MEM_DEPTH*4)) begin
            $display("FAIL: Data daddress %h out of range.", daddr);
        end
    end
    
    // Data write control
    always @(posedge clk) begin
        if (dwstrb) begin
            mem[daddr[31:2]] <= dwdata;
        end
    end
 
endmodule