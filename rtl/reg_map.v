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
    input  wire         clk,    // I    1 Rising-edge active system clock
    input  wire         rst_n,  // I    1 Active-low system reset

    // Data interface
    input  wire [4:0]   A1,     // I    5 Port 1 address
    input  wire [4:0]   A2,     // I    5 Port 2 address
    input  wire [4:0]   A3,     // I    5 Port 3 address
    output wire [31:0]  RD1,    // O   32 Port 1 read data
    output wire [31:0]  RD2,    // O   32 Port 2 read data
    input  wire [31:0]  WD3,    // I   32 Port 3 write data
    input  wire         WE3     // I    1 Port 3 write enable
);

    integer i;
    reg  [31:0] mem [0:31]; // Register map

    assign RD1 = mem[A1];
    assign RD2 = mem[A2];
    
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
