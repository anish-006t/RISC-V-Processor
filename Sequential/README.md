# Sequential RV64I Processor -- Phase I

## Overview


This project implements a 64-bit Sequential (Non-Pipelined) RISC-V
Processor in Verilog. The processor executes a subset of the RV64I base
integer instruction set using a single-cycle datapath architecture.

## Supported Instructions

-   add
-   sub
-   addi
-   and
-   or
-   ld
-   sd
-   beq

## Architecture

The processor consists of the following modules:

-   Program Counter (PC)
-   Instruction Memory (Big-endian)
-   Control Unit
-   Immediate Generator
-   ALU Control
-   64-bit ALU
-   Register File (32 × 64-bit, x0 hardwired to zero)
-   Data Memory (Big-endian)
-   PC + 4 Adder
-   Branch Target Adder

## File Structure

instruction_mem.v\
data_mem.v\
register_file.v\
control.v\
alu.v\
alu_control.v\
imm_gen.v\
pc.v\
pc_plus_4.v\
branch_targ_adder.v\
seq_tb.v\
instructions.txt\
register_file.txt


## Conclusion

The processor correctly executes arithmetic, memory, and branch
instructions in a sequential single-cycle architecture. The design is
modular, verified through simulation, and ready for future extension.

## How to run

Install dependencies (Debian/Ubuntu):

```bash
sudo apt-get update
sudo apt-get install -y iverilog gtkwave
```

Compile and run the integration testbench (`seq_tb.v`):

```bash
iverilog -o seq_sim.out *.v seq_tb.v
./seq_sim.out
```

Run an individual module testbench (example):

```bash
iverilog -o tb.out *.v tb/tb_alu_control.v
./tb.out
```

If a testbench writes a VCD file (waveform), open it with GTKWave:

```bash
gtkwave <testbench_name>.vcd
```
