# Pipelined MIPS Processor

### Five stages. Parallel instruction flow. A closer look at processor design.

An educational 32-bit MIPS-style processor in VHDL, organized around a five-stage pipeline with explicit interstage registers, a Fibonacci demonstration program, and FPGA controls for inspecting the datapath.

**VHDL · Vivado · FPGA · Pipelining · Computer Architecture**

---

## Overview

The design separates instruction processing into **Instruction Fetch**, **Instruction Decode**, **Execute**, **Memory**, and **Write-Back** stages. Registers between stages carry operands, addresses, destination register identifiers, and control signals through the datapath.

A button-generated enable advances the pipeline, while switches select internal values for an eight-digit hexadecimal display. The included Vivado project targets an Artix-7 FPGA.

This repository represents an educational pipeline implementation under development. It includes incomplete auxiliary modules and integration issues documented below; it should not be treated as a fully verified MIPS core.

## Features

- **Five-stage pipeline** with IF/ID, ID/EX, EX/MEM, and MEM/WB registers.
- **32-bit datapath** and a 32-register bank.
- **32-word instruction ROM** containing a Fibonacci-oriented program and commented instruction examples.
- **64-word data memory** with initialized contents.
- **Arithmetic, logic, shift, comparison, load/store, and control-flow paths**.
- **Falling-edge register writes** alongside rising-edge pipeline updates.
- **Manual pipeline stepping**, program-counter reset, and selectable datapath display.
- **PDF documentation** and schematic included in the repository.

## Tools and Target

| Item | Configuration |
| --- | --- |
| Language | VHDL |
| Tool | Vivado; included session logs identify version 2022.2 |
| FPGA part | `xc7a100tcsg324-1` |
| Project file | `MIPS_pipeline/MIPS_pipeline.xpr` |
| Design top | `test_env` |
| Configured simulation top | `test_env`; no dedicated testbench is included |
| External constraints reference | `NexysA7_test_env.xdc` |

Some source files use the legacy `STD_LOGIC_UNSIGNED` package alongside `NUMERIC_STD`. Other simulators may require compatibility options.

## Pipeline Architecture

```text
   IF       IF/ID       ID       ID/EX       EX       EX/MEM      MEM      MEM/WB      WB
 Fetch ──► Register ──► Decode ──► Register ──► ALU ──► Register ──► RAM ──► Register ──► Select
                          ▲                                                           │
                          └──────────────── Register write-back ───────────────────────┘
```

| Stage | Responsibility |
| --- | --- |
| IF | Read the instruction ROM and select the next PC. |
| ID | Decode the instruction, read registers, and extend the immediate. |
| EX | Execute the ALU operation, calculate the branch target, and select the destination register through the top-level pipeline logic. |
| MEM | Read or write data memory and expose the registered branch decision. |
| WB | Select memory data or the ALU result and write to the destination register. |

### Interstage registers

The active pipeline registers are implemented as clocked processes **inside `test_env.vhd`**:

| Signal | Width | Main contents |
| --- | --- | --- |
| `REG_IF_ID` | 64 bits | Instruction and `PC + 4`. |
| `REG_ID_EX` | 158 bits | Control signals, `PC + 4`, operands, immediate, shift amount, function code, `rt`, and `rd`. |
| `REG_EX_MEM` | 106 bits | Control signals, branch address, zero flag, ALU result, store data, and destination register. |
| `REG_MEM_WB` | 71 bits | Write-back controls, memory data, ALU result, and destination register. |

Pipeline registers update on rising clock edges when `en = '1'`. The register bank writes on falling edges when enabled and authorized by the write-back control signal.

The PC advances by **four bytes**. Instruction ROM indexing uses `PC(6 downto 2)`, data memory indexing uses address bits `7 downto 2`, and branch offsets are shifted left by two before being added to `PC + 4`.

## Instruction Paths

The control and ALU modules include decoding for:

| Group | Instructions |
| --- | --- |
| Register arithmetic | `ADD`, `SUB` |
| Register logic | `AND`, `OR`, `XOR` |
| Shift and comparison | `SLL`, `SRL`, signed `SLT` |
| Immediate operations | `ADDI`, `ANDI`, `ORI` |
| Memory | `LW`, `SW` |
| Control flow | `BEQ`, `J` |

These describe implemented decoding and datapath paths, rather than a claim of complete instruction verification. The all-zero instruction is used as a NOP through `SLL $0, $0, 0`.

## Demonstration Program

The active ROM in **`IFfetch.vhd`** contains a Fibonacci-oriented program. It initializes registers with zero and one, stores them at two memory addresses, reloads them, and repeatedly adds and moves values in a loop.

Explicit NOP entries separate some dependent operations. The ROM also contains a commented program illustrating the supported instruction paths.
