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
    // Control signals
    input  wire         clk,    // I    1 Rising-edge active system clock
    input  wire         rst_n,  // I    1 Active-low system reset
    input  wire         wen,    // I    1 Write enable
    
    // Memory interface
    input  wire [31:0]  addr,   // I   32 Read/Write data address
    input  wire [31:0]  wdat,   // I   32 Write data
    output wire [31:0]  rdat    // O   32 Read data
);

    reg  [31:0]   mem     [0:MEM_DEPTH-1];    // Memory array
    
    assign rdat = mem[addr[31:2]];

    // Address range check
    always @(*) begin
        if (addr >= MEM_DEPTH*4) begin
            $display("FAIL: Data address out of range");
        end
    end
    
    // Data write
    always @(posedge clk) begin
        if (wen) begin
            mem[addr[31:2]] <= wdat;
        end
    end
 
endmodule