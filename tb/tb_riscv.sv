/*******************************************************************************
 * 
 *  Copyright (c) 2026 Daniel Franc
 *  All Rights Reserved. Any reproduction, use or disclosure, in whole or in
 *  part, of this program, including any attempt to obtain a human-readable
 *  version of this program, without the express, prior written consent of the
 *  author is strictly prohibited.
 *
 *  Description:
 *  This file defines a risc-v cpu testbench.
 *
 *******************************************************************************/

`define timescale 1ns/1ps
`define default_nettype none
`define CLK_PERIOD 10   // 100 MHz clock

module tb_riscv;

    /***************************************************************************
    * Signal Declaration
    ****************************************************************************/

    // System clock and reset
    reg  clk;        // Clock
    reg  rst_n;      // Acitve-low reset

    // Instruction interface
    wire [31:0] iaddr;  // Instruction address
    wire [31:0] idata;  // Read instruction

    // Data interface
    wire [31:0] daddr;  // Read/Write data address
    wire [31:0] drdata; // Read data
    wire [31:0] dwdata; // Write data
    wire        dwstrb; // Data write enable

    string fw_file;     // Memory initialization file
    string test_name;   // Test being run

    /***************************************************************************
    * Submodule Instantiation
    ****************************************************************************/

    riscv u_riscv (
        // Control signals
        .clk    (clk    ),  // I    1 Clock
        .rst_n  (rst_n  ),  // I    1 Acitve-low reset

        // Instrunction interface
        .iaddr  (iaddr  ),  // O   32 Instruction address
        .idata  (idata  ),  // I   32 Read instruction

        // Data interface
        .daddr  (daddr  ),  // O   32 Data address
        .dwdata (dwdata ),  // O   32 Write data
        .dwstrb (dwstrb ),  // O    1 Write strobe
        .drdata (drdata ),  // I   32 Read data
        .dread  (dread  )   // O    1 Read strobe
    );

    imem # (
        .MEM_DEPTH  (8192   )   // Memory depth
    ) u_imem (
        // Memory interface
        .iaddr      (iaddr  ),  // I   32 Instruction address
        .idata      (idata  )   // O   32 Read instruction
    );

    dmem # (
        .MEM_DEPTH  (8192   )   // Memory depth
    ) u_dmem (
        // Clock, reset
        .clk        (clk    ),  // I    1 Clock
        .rst_n      (rst_n  ),  // I    1 Acitve-low reset
        
        // Memory interface
        .daddr      (daddr  ),  // I   32 Data address
        .dwdata     (dwdata ),  // I   32 Write data
        .dwstrb     (dwstrb ),  // I    1 Write strobe
        .drdata     (drdata ),  // O   32 Read data
        .dread      (dread  )   // I    1 Read strobe
    );

    /***************************************************************************
    * Testbench Logic
    ****************************************************************************/

    // Test name parsing
    initial begin
        if (!$value$plusargs("TEST=%s", test_name)) begin
            $display("Warning: +TEST argument missing.");
        end
    end

    // Memory initialization
    initial begin
        if ($value$plusargs("FIRMWARE=%s", fw_file)) begin
            $readmemh(fw_file, u_imem.mem);
            $readmemh(fw_file, u_dmem.mem);
        end else begin
            $display("Warning: +FIRMWARE argument missing.");
        end
    end

    // Clock generation
    initial begin
        clk = 1'b1;
        forever #(`CLK_PERIOD/2) clk = ~clk;
    end

    // Reset and timeout generation
    initial begin
        rst_n = 1'b0;
        #(3.5*`CLK_PERIOD);
        rst_n = 1'b1;
        #1000000; // 100 ms
        $display("TIMEOUT: Ebreak/ecall instruction not found.");
        $finish;
    end

    // Test completion detection
    always @(posedge clk) begin

        if (test_name == "gcd") begin
            // Specific test logic for GCD test (Ebreak triggered)
            if (u_riscv.u_riscv_id.u_ctrl_unit.isebreak) begin
                // Simulation result is saved in data memory at word address 256
                if (u_dmem.mem[256] == 32'd14) begin
                    $display("PASS");
                end else begin
                    $display("FAIL");
                end
                $finish;
            end
        
        end else if (test_name == "isa") begin
            // Specific test logic for ISA tests (Ecall triggered)
            if (u_riscv.u_riscv_id.u_ctrl_unit.isecall) begin
                // Simulation result is saved in the register x10
                if (u_riscv.u_riscv_id.u_reg_map.mem[10] == 32'd0) begin
                    $display("PASS");
                end else begin
                    $display("FAIL");
                end
                $finish;
            end
        end
    end

endmodule
