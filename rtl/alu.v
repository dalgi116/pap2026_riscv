/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines an arithmetic-logic unit used in risc-v cpu.
 *
 *******************************************************************************/

module alu (
    // ALU interface
    input  wire [2:0]   ctrl,   // I    3 Control vector
    input  wire [31:0]  srcA,   // I   32 Source port A
    input  wire [31:0]  srcB,   // I   32 Source port B
    output reg  [31:0]  res,    // O   32 Result port
    output wire         zero    // O    1 Zero flag
);

    assign zero = (res == 32'd0);

    always @(*) begin
        case (ctrl)
            3'b000: begin
                res = srcA + srcB;
            end
            3'b001: begin
                res = srcA - srcB;
            end
            3'b010: begin
                if ($signed(srcA) < $signed(srcB)) begin
                    res = 32'd1;
                end else begin
                    res = 32'd0;
                end
            end
            3'b011: begin
                res = srcA << srcB[4:0];
            end
            3'b100: begin
                res = srcB;
            end
            3'b101: begin
                res = srcA & srcB;
            end
            3'b110: begin
                res = srcA | srcB;
            end
            3'b111: begin
                res = $signed(srcA) >>> srcB[4:0];
            end
            default: begin
                res = 32'd0;
            end
        endcase
    end

endmodule
