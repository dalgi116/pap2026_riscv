/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines a control unit used in risc-v cpu.
 *
 *******************************************************************************/

module ctrl_unit (
    // Input interface
    input  wire [6:0]   opcode,     // I    7 Operation code
    input  wire [2:0]   funct3,     // I    3 Function code 3
    input  wire [6:0]   funct7,     // I    6 Function code 7
    input  wire         aluzero,    // I    1 ALU zero flag
    
    // Output interface
    output reg          pcsrc,      // O    1 Instruction address select
    output reg          pcsrc_jalr, // O    1 JALR jump flag
    output reg          mem2reg,    // O    1 Register map WD3 select
    output reg          alusrc,     // O    1 ALU SrcB select
    output reg          regwrite,   // O    1 Register map WE3
    output reg          memwrite,   // O    1 Data memory write enable
    output reg  [2:0]   immsrc,     // O    3 Immediate source select
    output reg  [2:0]   aluctrl     // O    3 Combinational ALU control vector
);

    // Immediate source select encoding
    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_U = 3'b011;
    localparam IMM_J = 3'b100;

    // Main decoder
    always @(*) begin
        pcsrc      = 1'b0;
        pcsrc_jalr = 1'b0;
        mem2reg    = 1'b0;
        alusrc     = 1'b0;
        regwrite   = 1'b0;
        memwrite   = 1'b0;
        immsrc     = IMM_I;
        aluctrl    = 3'b000;

        case (opcode)
            // LUI (Load Upper Immediate)
            7'b0110111: begin
                regwrite = 1'b1;
                immsrc   = IMM_U;
                alusrc   = 1'b1;
                aluctrl  = 3'b100;
            end
            
            // AUIPC (Add Upper Immediate to PC)
            7'b0010111: begin
                regwrite = 1'b1;
                immsrc   = IMM_U;
                alusrc   = 1'b1; 
                aluctrl  = 3'b000;
            end

            // JAL (Jump and Link)
            7'b1101111: begin
                regwrite = 1'b1;
                immsrc   = IMM_J;
                pcsrc    = 1'b1;
            end

            // JALR (Jump and Link Register)
            7'b1100111: begin
                regwrite   = 1'b1;
                immsrc     = IMM_I;
                pcsrc_jalr = 1'b1;
                aluctrl    = 3'b000;
            end

            // Branches or jumps (B-Type)
            7'b1100011: begin
                immsrc = IMM_B;
                case (funct3)
                    3'b000: begin
                        pcsrc   = aluzero;  // BEQ
                        aluctrl = 3'b001;
                    end
                    3'b001: begin
                        pcsrc   = ~aluzero; // BNE
                        aluctrl = 3'b001;
                    end
                    3'b100: begin
                        pcsrc   = ~aluzero; // BLT
                        aluctrl = 3'b010;
                    end
                    default: begin
                        pcsrc = 1'b0;
                    end
                endcase
            end

            // Memory load (Load / I-Type)
            7'b0000011: begin
                // LW
                regwrite = 1'b1;
                mem2reg  = 1'b1;
                alusrc   = 1'b1;
                immsrc   = IMM_I;
                aluctrl  = 3'b000;
            end

            // Memory store (Store / S-Type)
            7'b0100011: begin
                // SW
                memwrite = 1'b1;
                alusrc   = 1'b1;
                immsrc   = IMM_S;
                aluctrl  = 3'b000;
            end

            // Arithmetic and logic with Immediate (I-Type)
            7'b0010011: begin
                regwrite = 1'b1;
                alusrc   = 1'b1;
                immsrc   = IMM_I;
                case (funct3)
                    3'b000: aluctrl = 3'b000; // ADDI
                    3'b001: aluctrl = 3'b011; // SLLI
                    3'b101: begin
                        if (funct7 == 7'b0100000) begin
                            aluctrl = 3'b111; // SRAI
                        end
                    end
                    3'b110: aluctrl = 3'b110; // ORI
                    3'b111: aluctrl = 3'b101; // ANDI
                    default: aluctrl = 3'b000;
                endcase
            end

            // Arithmetic and logic operations between registers (R-Type)
            7'b0110011: begin
                regwrite = 1'b1;
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000) 
                            aluctrl = 3'b001; // SUB
                        else 
                            aluctrl = 3'b000; // ADD
                    end
                    3'b001: aluctrl = 3'b011; // SLL
                    3'b010: aluctrl = 3'b010; // SLT
                    3'b110: aluctrl = 3'b110; // OR
                    3'b111: aluctrl = 3'b101; // AND
                    default: aluctrl = 3'b000;
                endcase
            end

            default: begin
                // Above
            end
        endcase
    end

endmodule
