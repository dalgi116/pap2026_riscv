# RISC-V CPU
**Author:** Daniel Franc  
**Year:** 2026  

## About This Repository

This repository contains a RISC-V processor developed as a school project. The processor implements a mandatory reduced instruction set, specifically supporting the following instructions: `add`, `addi`, `and`, `andi`, `auipc`, `beq`, `blt`, `bne`, `jal`, `jalr`, `lui`, `lw`, `lui`, `or`, `ori`, `sll`, `slli`, `slt`, `srai`, `sub` and `sw`.

The project assignment requires the following milestones:
1. Create a single-cycle RISC-V CPU.
2. Run official RISC-V tests to verify support for the required instructions.
3. Write assembly code that loads two numbers from memory, jumps to a function that calculates the greatest common divisor (GCD), and returns.
4. Extend the CPU to a pipelined architecture.

*Note: QuestaSim software was used for simulation and verification. If other software is used, changes in `work/` folder are necessary.*

## Repository Structure

| Directory | Description |
| :--- | :--- |
| `rtl/` | Synthesizable RTL files |
| `tb/` | SystemVerilog testbenches and memory models |
| `sw/` | Software files and compilation products |
| `work/` | Simulation and verification workspace |

**Official ISA tests**
To run ISA tests, firstly install and set up QuestaSim. Then, go to `work/isa_tests/` and run `run_tests.sh`.

## Instruction Decode Example

The school assignment requires an explanation of the instruction decoding process. Below are two examples of how instructions are decoded in this project:

### Example 1: `auipc`
**Instruction:** `0x00000517` (`00000000000000000000_01010_0010111`)
* **opcode:** `0010111`
* **FMT:** U
* **rd:** 10
* **imm:** 0
* **ins:** `auipc`

### Example 2: `slli`
**Instruction:** `0x00139713` (`000000000001_00111_001_01110_0010011`)
* **opcode:** `0010011`
* **FMT:** I
* **rd:** 14
* **funct3:** 1
* **rs1:** 7
* **ins:** `slli`