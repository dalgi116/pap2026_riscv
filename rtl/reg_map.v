/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines a register map used in risc-v cpu.
 *
 *******************************************************************************/

module reg_map (
    // Clock, reset
    input  wire         clk,    // I    1 Clock
    input  wire         rst_n,  // I    1 Acitve-low reset

    // Read interface
    input  wire [4:0]   A1,     // I    5 Read port 1 address
    input  wire [4:0]   A2,     // I    5 Read port 2 address
    output wire [31:0]  RD1,    // O   32 Read port 1 data
    output wire [31:0]  RD2,    // O   32 Read port 2 data
    
    // Write interface
    input  wire [4:0]   A3,     // I    5 Write port 3 address
    input  wire [31:0]  WD3,    // I   32 Write port 3 data
    input  wire         WE3     // I    1 Write port 3 write enable
);

    /***************************************************************************
    * Signal declaration
    ****************************************************************************/

    integer i;
    reg  [31:0] mem [0:31]; // Register map

    /***************************************************************************
    * Combinational logic
    ****************************************************************************/

    // Register read data
    assign RD1 = mem[A1];
    assign RD2 = mem[A2];

    /***************************************************************************
    * Sequential logic
    ****************************************************************************/
    
    // Register map write control
    always @(posedge clk or negedge rst_n) begin
        mem[0] <= 32'h0000_0000;

        if (!rst_n) begin
            for (i = 1; i < 32; i = i + 1) begin
                mem[i] <= 32'h0000_0000;
            end
        end else if (WE3 && (A3 != 5'd0)) begin
            mem[A3] <= WD3;
        end
    end
endmodule
