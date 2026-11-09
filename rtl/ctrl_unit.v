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

module ctrl_unit # (
    // Instruction format encoding
    parameter FMT_I = 3'b000,   //  I-type
    parameter FMT_S = 3'b001,   //  S-type
    parameter FMT_B = 3'b010,   // SB-type
    parameter FMT_U = 3'b011,   //  U-type
    parameter FMT_J = 3'b100,   // UJ-type
    parameter FMT_R = 3'b101    //  R-type
) (
    // Input interface
    input  wire [31:0]  idata,      // I   32 Read instruction
    
    // Output interface
    output reg          regwrite,   // O    1 Register map WE3
    output reg          memtoreg,   // O    1 Register map WD3 select
    output reg          memwrite,   // O    1 Data memory write enable
    output reg          memread,    // O    1 Data memory read enable
    output reg          bbxx,       // O    1 Branch if condition is met
    output reg          bjal,       // O    1 JAL instruction
    output reg          bjalr,      // O    1 JALR instruction
    output reg          bval,       // O    1 Branch condition if ALU result is zero
    output reg  [2:0]   aluctrl,    // O    3 ALU control
    output reg          alusrc,     // O    1 ALU SrcB select
    output reg          auipc,      // O    1 AUIPC instruction
    output reg  [2:0]   format      // O    3 Instruction format
);

    /***************************************************************************
    * Signal declaration
    ****************************************************************************/

    // Instruction fields
    wire [6:0] opcode;  // Instruction opcode
    wire [2:0] funct3;  // Instruction funct3
    wire [6:0] funct7;  // Instruction funct7

    /***************************************************************************
    * Combinational logic
    ****************************************************************************/
    
    // Instruction decode
    assign opcode = idata[6:0];
    assign funct3 = idata[14:12];
    assign funct7 = idata[31:25];

    // Main decoder
    always @(*) begin
        // Default values
        regwrite = 1'b0;
        memtoreg = 1'b0;
        memwrite = 1'b0;
        memread  = 1'b0;
        bbxx     = 1'b0;
        bjal     = 1'b0;
        bjalr    = 1'b0;
        bval     = 1'b0;
        alusrc   = 1'b0;
        auipc    = 1'b0;
        format   = FMT_I;

        case (opcode)
            // AUIPC (Add Upper Immediate to PC)
            7'b0010111: begin
                regwrite = 1'b1;
                alusrc   = 1'b1;
                auipc    = 1'b1;
                format   = FMT_U;
            end
            // LUI (Load Upper Immediate)
            7'b0110111: begin
                regwrite = 1'b1;
                alusrc   = 1'b1;
                format   = FMT_U;
            end            
            // SW (Store Word)
            7'b0100011: begin
                memwrite = 1'b1;
                alusrc   = 1'b1;
                format   = FMT_S;
            end
            // JAL (Jump and Link)
            7'b1101111: begin
                regwrite = 1'b1;
                bjal     = 1'b1;
                format   = FMT_J;
            end
            // JALR (Jump and Link Register)
            7'b1100111: begin
                regwrite = 1'b1;
                bjalr    = 1'b1;
                alusrc   = 1'b1;
                format   = FMT_I;
            end
            // LW (Load Word)
            7'b0000011: begin
                regwrite = 1'b1;
                memtoreg = 1'b1;
                memread  = 1'b1;
                alusrc   = 1'b1;
                format   = FMT_I;
            end
            // Branches (SB-Type)
            7'b1100011: begin
                bbxx   = 1'b1;
                format = FMT_B;
            end
            // Arithmetic with Immediate (I-Type)
            7'b0010011: begin
                regwrite = 1'b1;
                alusrc   = 1'b1;
                format   = FMT_I;
            end
            // Arithmetic between registers (R-Type)
            7'b0110011: begin
                regwrite = 1'b1;
                format   = FMT_R;
            end
        endcase
    end

    // ALU decoder
    always @(*) begin
        // Default values
        aluctrl = 3'b000;
        bval    = 1'b0;

        case (format)
            FMT_B: begin    // SB-Type
                case (funct3)
                    3'b000: begin   // BEQ
                        aluctrl = 3'b001;
                        bval    = 1'b1;
                    end 
                    3'b001: aluctrl = 3'b001;   // BNE
                    3'b100: aluctrl = 3'b010;   // BLT
                endcase
            end
            FMT_R: begin    // R-Type
                case (funct3)
                    3'b000: aluctrl = (funct7 == 7'b0100000) ? 3'b001 : 3'b000; // SUB : ADD
                    3'b001: aluctrl = 3'b011;   // SLL
                    3'b010: aluctrl = 3'b010;   // SLT
                    3'b101: aluctrl = 3'b111;   // SRA
                    3'b110: aluctrl = 3'b110;   // OR
                    3'b111: aluctrl = 3'b101;   // AND
                endcase
            end
            FMT_I: begin    // I-Type
                if (opcode == 7'b0000011) begin
                    aluctrl = 3'b000; // LW requires ADD for address calculation
                end else begin
                    case (funct3)
                        3'b000: aluctrl = 3'b000; // ADDI
                        3'b001: aluctrl = 3'b011; // SLLI
                        3'b010: aluctrl = 3'b010; // SLTI
                        3'b101: aluctrl = 3'b111; // SRAI
                        3'b110: aluctrl = 3'b110; // ORI
                        3'b111: aluctrl = 3'b101; // ANDI
                    endcase
                end
            end
            FMT_U: begin   // U-Type
                if (opcode == 7'b0110111) begin
                    aluctrl = 3'b100; // LUI
                end else begin
                    aluctrl = 3'b000; // AUIPC
                end
            end
            default: begin 
                // SW, JALR
                // All of these require basic addition (rs1+imm or pc+imm)
                aluctrl = 3'b000; 
            end
        endcase
    end

endmodule
