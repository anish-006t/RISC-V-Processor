# RISC-V Processor Implementation

A comprehensive Verilog implementation of a 64-bit RISC-V processor featuring both **sequential (single-cycle)** and **5-stage pipelined** architectures with advanced hazard detection and data forwarding mechanisms.

## Table of Contents

- [Project Overview](#project-overview)
- [Supported Instructions](#supported-instructions)
- [Architecture](#architecture)
  - [Sequential (Non-Pipelined) Design](#sequential-non-pipelined-design)
  - [Pipelined Design](#pipelined-design)
- [Data Hazard Handling](#data-hazard-handling)
- [Project Structure](#project-structure)
- [How to Run](#how-to-run)
- [Compilation and Testing](#compilation-and-testing)

---

## Project Overview

This project implements a 64-bit RISC-V processor with two design variants:

1. **Sequential Processor** (`Sequential/`) - Single-cycle execution, simple control logic, deterministic performance
2. **Pipelined Processor** (`Pipeline/`) - 5-stage pipeline with hazard detection, forwarding, and optimizations

Both implementations support a subset of the RV64I base integer instruction set and are designed for educational purposes to demonstrate processor design principles.

### Key Features

- **64-bit RISC-V ISA (RV64I)** with subset of instructions
- **Register File**: 32 × 64-bit registers (x0 hardwired to zero)
- **Memory**: Instruction and Data memory with big-endian byte ordering
- **Pipeline Optimization**: Forwarding and hazard detection units in pipelined version
- **Modular Design**: Well-organized, synthesizable Verilog modules
- **Simulation Support**: Complete testbenches with VCD waveform dump capability

---

## Supported Instructions

The processor supports the following 8 RISC-V instructions:

### Arithmetic Instructions (R-type)
- **add** - Add: `rd = rs1 + rs2`
- **sub** - Subtract: `rd = rs1 - rs2`
- **and** - Bitwise AND: `rd = rs1 & rs2`
- **or** - Bitwise OR: `rd = rs1 | rs2`

### Immediate Instructions (I-type)
- **addi** - Add Immediate: `rd = rs1 + imm[11:0]`

### Load/Store Instructions
- **ld** - Load Doubleword (64-bit): `rd = mem[rs1 + imm[11:0]]`
- **sd** - Store Doubleword (64-bit): `mem[rs1 + imm[11:0]] = rs2`

### Branch Instructions (B-type)
- **beq** - Branch if Equal: `if (rs1 == rs2) PC = PC + imm[12:1]`

---

## Architecture

### Sequential (Non-Pipelined) Design

The sequential processor executes one instruction per clock cycle through all stages in a single pass:

```
IF → ID → EX → MEM → WB (all in one cycle)
```

**Modules:**
- `pc.v` - Program Counter with reset capability
- `instruction_mem.v` - 64-bit wide instruction memory
- `data_mem.v` - Data memory for load/store operations
- `reg_file.v` - 32 × 64-bit register file
- `control.v` - Instruction decoder and control signal generator
- `alu_control.v` - ALU function selector based on opcode and funct3/funct7
- `alu.v` - 64-bit Arithmetic-Logic Unit
- `imm_gen.v` - Immediate value decoder for I, S, and B type instructions
- `pc_plus_4.v` - Adder for sequential PC increment
- `branch_targ_adder.v` - Adder for branch target calculation

**Advantages:**
- Simple control logic
- No hazard detection required
- Predictable timing for every instruction

**Disadvantages:**
- Limited throughput (1 instruction per cycle)
- No instruction-level parallelism

---

### Pipelined Design

The 5-stage pipelined processor overlaps instruction execution to improve throughput:

```
Stage 1 (IF):   Instruction Fetch
Stage 2 (ID):   Instruction Decode & Register Read
Stage 3 (EX):   Execute & Address Calculation
Stage 4 (MEM):  Memory Access (Load/Store)
Stage 5 (WB):   Register Write-back

Multiple instructions can be in different stages simultaneously.
```

**Pipeline Stages:**

1. **IF (Instruction Fetch)**: Fetch 32-bit instruction from memory, increment PC
2. **ID (Instruction Decode)**: Decode opcode, read registers, generate control signals
3. **EX (Execute)**: ALU operations, address calculation for branches
4. **MEM (Memory)**: Load/Store operations on data memory
5. **WB (Write-back)**: Write results back to register file

**Pipeline Registers:**
- `if_id_reg.v` - Latches IF stage outputs to ID stage
- `id_ex_reg.v` - Latches ID stage outputs to EX stage
- `ex_mem_reg.v` - Latches EX stage outputs to MEM stage
- `mem_wb_reg.v` - Latches MEM stage outputs to WB stage

**Additional Modules:**
- `hazard_detection_unit.v` - Detects load-use hazards and issues pipeline stalls
- `forwarding_unit.v` - Forwards ALU results to prevent data hazards
- `mux.v`, `mux2.v` - Multiplexers for data path selection

**Advantages:**
- Higher throughput: Up to 5 instructions in flight simultaneously
- Better utilization of hardware resources
- Theoretical speedup of ~5x for long instruction sequences

**Disadvantages:**
- More complex control logic
- Requires hazard detection and forwarding mechanisms
- Potential for pipeline bubbles and stalls

---

## Data Hazard Handling

Data hazards occur when an instruction depends on the result of a previous instruction that hasn't been committed. This processor uses two complementary mechanisms:

### 1. **Forwarding (Operand Forwarding)**

**Purpose**: Bypass data from earlier pipeline stages directly to the EX stage, eliminating unnecessary stalls for most hazards.

**Implementation** (`forwarding_unit.v`):

The forwarding unit monitors the `rd` (destination register) of instructions in the EX/MEM and MEM/WB stages and compares them with `rs1` and `rs2` (source registers) of the instruction currently in the EX stage.

**Forwarding Paths:**
- **EX Hazard (MEM → EX)**: When `exmem_RegWrite = 1` and `exmem_rd = idex_rs1/rs2`:
  - Forward ALU result from EX/MEM stage directly to ALU inputs
  - `forward_a = 2'b10` or `forward_b = 2'b10`
  
- **MEM Hazard (WB → EX)**: When `memwb_RegWrite = 1` and `memwb_rd = idex_rs1/rs2`:
  - Forward write-back data from MEM/WB stage to ALU
  - `forward_a = 2'b01` or `forward_b = 2'b01`

**Example (No Stall Required):**
```
Cycle 1: add x1, x2, x3   (writes x1 in WB stage)
Cycle 2: addi x4, x1, 10  (reads x1 - uses forwarded value from previous add)
Cycle 3: sub x5, x4, x6
```

The `addi` instruction doesn't need to wait; it receives the result of `add` via forwarding.

### 2. **Hazard Detection (Load-Use Hazard Unit)**

**Purpose**: Detect load-use hazards that cannot be resolved by forwarding alone and issue pipeline stalls.

**Implementation** (`hazard_detection_unit.v`):

Load-use hazards occur when:
1. The previous instruction is a **load** (`ld`)
2. The current instruction **uses** the loaded value as a source operand

This pattern cannot be resolved by forwarding because the load doesn't have the data until the MEM stage, but the next instruction needs it in the EX stage.

**Detection Logic:**
```verilog
load_use_hazard = idex_MemRead &&              // Previous instruction is a load
                  (idex_rd != 5'd0) &&         // Destination is not x0
                  ((rs1_used && (idex_rd == ifid_rs1)) ||  // rs1 matches load rd
                   (rs2_used && (idex_rd == ifid_rs2)));    // rs2 matches load rd
```

**Source Register Usage:**
- Used in R-type, I-type arithmetic, Load, Store, and Branch instructions
- Not used in immediate-only operations

**Stall Actions** (when `load_use_hazard = 1`):
1. **Stall IF/ID Register**: Prevent new instruction from entering ID stage
2. **Stall PC**: Keep PC unchanged, re-fetch same instruction next cycle
3. **Insert Pipeline Bubble**: Cancel ID/EX register, prevent invalid operation
4. **Repeat Until Data Available**: After the load data reaches WB stage, forwarding resolves the hazard

**Example (Stall Required):**
```
Cycle 1: ld x1, 0(x2)     (Load x1 from memory)
Cycle 2: add x3, x1, x4   STALL! (x1 not available at EX stage)
Cycle 3: add x3, x1, x4   (Now x1 is forwarded from MEM stage)
Cycle 4: sub x5, x3, x6
```

Without the stall, `add` would use incorrect data for `x1`.

---

## Project Structure

```
RISC-V-Processor/
├── README.md                          # This file
├── Sequential/                        # Single-cycle processor
│   ├── processor.v                    # Top-level sequential processor
│   ├── seq_tb.v                       # Sequential testbench
│   ├── control.v                      # Control unit (instruction decoder)
│   ├── alu.v, alu_control.v          # ALU and control logic
│   ├── reg_file.v                     # 32 × 64-bit register file
│   ├── instruction_mem.v              # Instruction memory
│   ├── data_mem.v                     # Data memory
│   ├── imm_gen.v                      # Immediate generator
│   ├── pc.v, pc_plus_4.v             # Program counter and incrementer
│   ├── branch_targ_adder.v            # Branch address calculator
│   ├── mux.v, mux2.v                 # Multiplexers
│   ├── code.txt                       # Assembly instructions (input for compiler)
│   ├── compiler.py                    # Assembler (converts code.txt to instructions.txt)
│   ├── instructions.txt               # Assembled machine code (one byte per line)
│   ├── register_file.txt              # Register state output
│   └── README.md                      # Sequential processor documentation
│
└── Pipeline/                          # 5-stage pipelined processor
    ├── pipe_processor.v               # Top-level pipelined processor
    ├── pipe_tb.v                      # Pipelined testbench
    ├── if_id_reg.v, id_ex_reg.v       # Pipeline registers (IF/ID, ID/EX)
    ├── ex_mem_reg.v, mem_wb_reg.v     # Pipeline registers (EX/MEM, MEM/WB)
    ├── hazard_detection_unit.v        # Load-use hazard detector
    ├── forwarding_unit.v              # Data forwarding logic
    ├── control.v                      # Control unit
    ├── alu.v, alu_control.v          # ALU and control
    ├── reg_file.v                     # Register file
    ├── instruction_mem.v              # Instruction memory
    ├── data_mem.v                     # Data memory
    ├── imm_gen.v                      # Immediate generator
    ├── pc.v, pc_plus_4.v             # Program counter components
    ├── branch_targ_adder.v            # Branch calculator
    ├── mux.v, mux2.v                 # Multiplexers
    ├── code.txt                       # Assembly code input
    ├── compiler.py                    # Assembler
    ├── instructions.txt               # Machine code output
    ├── register_file.txt              # Register state output
    ├── pipe_tb.vcd                    # Waveform dump (generated after simulation)
    └── (other ALU operation modules: and.v, or.v, sll.v, slt.v, etc.)
```

---

## How to Run

### Prerequisites

Install the Verilog simulation tools on Linux/macOS:

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install -y iverilog gtkwave
```

**macOS (with Homebrew):**
```bash
brew install icarus-verilog gtkwave
```

---

### Compilation and Testing

### Sequential Processor

**Step 1: Write Assembly Code**

Edit `Sequential/code.txt` with your RISC-V assembly program:

```assembly
# Example: Calculate 5 + 3
addi x1, x0, 5      # x1 = 5
addi x2, x0, 3      # x2 = 3
add x3, x1, x2      # x3 = x1 + x2 = 8
beq x0, x0, 0       # Infinite loop (branch to self)
```

**Step 2: Compile Assembly to Machine Code**

```bash
cd Sequential/
python3 compiler.py
```

This generates `instructions.txt` containing the machine code.

**Step 3: Run Simulation**

```bash
iverilog -o seq_sim seq_tb.v *.v
./seq_sim
```

**Step 4: View Results**

- Check `register_file.txt` for final register values
- Open waveform if VCD is generated (check `seq_tb.v` for dump paths)

---

### Pipelined Processor

**Step 1: Write Assembly Code**

Edit `Pipeline/code.txt` with your RISC-V assembly:

```assembly
# Example: Demonstrate forwarding and hazard handling
addi x1, x0, 10     # x1 = 10
addi x2, x0, 5      # x2 = 5
add x3, x1, x2      # x3 = 15 (forwarded from EX stage)
ld x4, 0(x3)        # Load from mem[15]
add x5, x4, x1      # Add (may stall if load-use hazard)
beq x0, x0, 0       # Halt
```

**Step 2: Compile Assembly**

```bash
cd Pipeline/
python3 compiler.py
```

**Step 3: Run Simulation**

```bash
iverilog -o pipe_sim pipe_tb.v *.v
./pipe_sim
```

**Step 4: Analyze Performance**

- Check `register_file.txt` for results
- View `pipe_tb.vcd` waveform to see:
  - Pipeline stages and stalls
  - Forwarding signals activation
  - Hazard detection events

**View Waveforms (GTKWave):**

```bash
gtkwave pipe_tb.vcd
```

In GTKWave, expand the hierarchy to view:
- PC progression and stalls
- Pipeline register contents
- Forwarding signals (`forward_a`, `forward_b`)
- Hazard detection signals (`load_use_hazard`)
- ALU inputs and outputs

---

## Instruction Encoding Reference

### R-type Instructions (Arithmetic)
```
Format: | funct7[6:0] | rs2[4:0] | rs1[4:0] | funct3[2:0] | rd[4:0] | opcode[6:0] |
Bits:   |  [31:25]    | [24:20]  | [19:15]  |  [14:12]    | [11:7]  |   [6:0]    |

Examples:
- add:  funct7=0b0000000, funct3=0b000, opcode=0b0110011
- sub:  funct7=0b0100000, funct3=0b000, opcode=0b0110011
- and:  funct7=0b0000000, funct3=0b111, opcode=0b0110011
- or:   funct7=0b0000000, funct3=0b110, opcode=0b0110011
```

### I-type Instructions (Immediate Arithmetic & Load)
```
Format: | imm[11:0] | rs1[4:0] | funct3[2:0] | rd[4:0] | opcode[6:0] |
Bits:   | [31:20]   | [19:15]  |  [14:12]    | [11:7]  |   [6:0]    |

Examples:
- addi: funct3=0b000, opcode=0b0010011
- ld:   funct3=0b011, opcode=0b0000011
```

### S-type Instructions (Store)
```
Format: | imm[11:5] | rs2[4:0] | rs1[4:0] | funct3[2:0] | imm[4:0] | opcode[6:0] |
Bits:   | [31:25]   | [24:20]  | [19:15]  |  [14:12]    | [11:7]   |   [6:0]    |

Examples:
- sd:   funct3=0b011, opcode=0b0100011
```

### B-type Instructions (Branch)
```
Format: | imm[12] | imm[10:5] | rs2[4:0] | rs1[4:0] | funct3[2:0] | imm[4:1] | imm[11] | opcode[6:0] |
Bits:   | [31]    | [30:25]   | [24:20]  | [19:15]  |  [14:12]    | [11:8]   | [7]     |   [6:0]    |

Examples:
- beq:  funct3=0b000, opcode=0b1100011
```

---

## Testing & Debugging Tips

### Common Issues

1. **"Illegal opcode" error**: Check that `code.txt` uses only supported instructions (add, sub, addi, and, or, ld, sd, beq)
2. **Incorrect register values**: Check that `compiler.py` correctly encodes your assembly
3. **Pipeline stalls not working**: Verify `hazard_detection_unit.v` is connected in `pipe_processor.v`
4. **Forwarding issues**: Check `forwarding_unit.v` is properly wired to ALU input multiplexers

### Debugging Workflow

1. **Start simple**: Test single instructions first (e.g., `addi x1, x0, 5`)
2. **Use simulation output**: Print register values: `$display("x1 = %d", reg_file[1]);`
3. **Inspect waveforms**: Use GTKWave to trace signal changes cycle-by-cycle
4. **Enable detailed logging**: Modify testbenches to print instruction being executed

---

## Performance Metrics

### Sequential Processor
- **CPI (Cycles Per Instruction)**: 1
- **Throughput**: 1 instruction/cycle
- **Max Frequency**: Limited only by longest critical path
- **No stalls or hazards**

### Pipelined Processor (Ideal - No Hazards)
- **CPI**: ~1.2 (with pipeline fill/drain overhead)
- **Throughput**: ~4-5 instructions/cycle (after 5 cycles)
- **Pipeline Depth**: 5 stages
- **Potential Speedup**: ~4-5×

### Pipelined Processor (With Hazards)
- **Load-Use Stalls**: 1 cycle per hazard
- **Branch Misprediction**: Not implemented; branches always stall for safety
- **Actual CPI**: Depends on instruction mix and memory access patterns

---

## Future Enhancements

- [ ] Add more instructions (shift operations, multiply, divide)
- [ ] Implement branch prediction to reduce branch penalties
- [ ] Add caches for improved memory performance
- [ ] Support for exceptions and interrupts
- [ ] 32-bit variant (RV32I)
- [ ] Out-of-order execution with dynamic scheduling
- [ ] Implement full branch forwarding (currently each branch stalls)

---

## References

- [RISC-V ISA Specification](https://riscv.org/specifications/)
- [Computer Architecture: A Quantitative Approach](https://www.elsevier.com/books/computer-architecture/hennessy/978-0-12-811905-1)
- [Verilog Language Reference](https://en.wikipedia.org/wiki/Verilog)

---

## Author Notes

This processor implementation is designed for educational purposes to demonstrate:
- CPU pipeline design and operation
- Data hazard detection and resolution
- Operand forwarding techniques
- Memory hierarchy concepts
- Instruction encoding and decoding

The modular design allows for easy extension with additional instructions and advanced features.

**Last Updated**: March 2026
