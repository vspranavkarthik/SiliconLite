# SiliconLite — 5-Stage Pipelined RISC Processor

SiliconLite is an educational 32-bit RISC processor implemented in Verilog. The project demonstrates a five-stage instruction pipeline, arithmetic and logical operations, memory access, data forwarding, load-use hazard detection, branch handling, functional verification, and generic logic synthesis.

## Project Overview

The processor uses five pipeline stages:

1. **IF — Instruction Fetch**
2. **ID — Instruction Decode**
3. **EX — Execute**
4. **MEM — Memory Access**
5. **WB — Write Back**

Pipeline registers separate the stages, allowing multiple instructions to be processed concurrently.

## Features

- Five-stage pipelined processor architecture.
- Verilog RTL implementation.
- Arithmetic and logical instructions.
- Load and store operations.
- Conditional branches.
- EX/MEM and MEM/WB forwarding.
- Load-use hazard detection and stall insertion.
- Branch redirection and pipeline flushing.
- Self-checking Verilog testbench.
- ModelSim functional simulation.
- Yosys generic synthesis and netlist generation.
- Waveform-based debugging and analysis.

## Supported Instructions

| Instruction class | Instructions |
|---|---|
| R-type | ADD, SUB, AND, OR, XOR, SLT |
| Immediate | ADDI |
| Memory | LW, SW |
| Conditional branch | BEQ, BNE |

**Note:** SiliconLite implements an educational instruction subset. It is not a complete implementation of the RISC-V RV32I specification.

## Project Structure

```text
SiliconLite/
├── rtl/
│   └── siliconlite_cpu.v
├── tb/
│   └── tb_siliconlite_cpu.v
├── scripts/
│   ├── run_modelsim.do
│   ├── run_yosys.sh
│   └── synth_yosys.ys
├── programs/
├── docs/
│   ├── verification_plan.md
│   └── qor_template.md
├── Waveforms/
├── build/
│   ├── simulation_final.log
│   ├── yosys.log
│   └── siliconlite_generic_netlist.v
├── SiliconLite_Project_Report.pdf
├── SiliconLite_Project_Presentation.pptx
├── LIVE_PROJECT_LINK.txt
└── README.md
```

Some generated files may be absent until the corresponding simulation or synthesis script is run.

## Tools Used

- **RTL design:** Verilog
- **Functional simulation:** ModelSim Intel FPGA Edition 10.5b
- **Generic synthesis:** Yosys 0.70+221
- **Operating environment:** Windows with OSS CAD Suite available for synthesis

## Running the Functional Simulation

Open a command prompt with ModelSim available and navigate to the project directory:

```bat
cd /d C:\SiliconLite
vsim -c -do scripts\run_modelsim.do
```

The script compiles the processor and testbench, runs the simulation, prints the verification summary, and exits.

### Recorded Verification Results

The included final simulation transcript reports:

| Metric | Result |
|---|---:|
| Functional checks passed | 12 |
| Active cycles | 65 |
| Load-use stalls | 1 |
| Taken branches | 2 |
| Compilation/simulation errors | 0 |
| Simulation warnings | 0 |
| Final status | PASS |

The testbench checks expected register values and the load/store memory result, and tracks selected instruction classes, stalls, and taken branches.

To reproduce these results, run the simulation script and inspect the resulting transcript. Results may differ if the RTL, testbench, or test program is changed.

## Running Generic Synthesis

With OSS CAD Suite configured in the command prompt, run:

```bat
cd /d C:\SiliconLite
yosys -l build\yosys.log -s scripts\synth_yosys.ys
```

The synthesis flow reads the RTL, checks the design hierarchy, lowers processes, optimizes logic, maps internal structures to generic cells, prints statistics, and writes a generic Verilog netlist.

### Recorded Synthesis Results

The included Yosys log reports:

| Metric | Result |
|---|---:|
| Generic logic cells | 112 |
| AND cells | 49 |
| NOT cells | 1 |
| `$_SDFF_PP0_` cells | 33 |
| XOR cells | 29 |
| Netlist generated | Yes |

The netlist is saved as `build/siliconlite_generic_netlist.v`.

**Interpretation:** These are generic synthesis statistics, not mapped physical area, power consumption, maximum operating frequency, or timing-closure results. Those metrics require an appropriate target technology, constraints, and further implementation analysis.

## Verification Evidence

The `Waveforms/` directory contains waveform screenshots used to inspect processor operation, pipeline signals, branch control, and hazard behavior.

The `build/` directory contains simulation and synthesis evidence. Review the logs when reproducing the project or validating changes.

## Limitations and Future Work

The current design is an educational processor subset and has not been demonstrated as a complete RV32I implementation or a physically implemented ASIC/FPGA design.

Potential improvements include:

- Broader instruction-level regression tests.
- Reference-model-based verification.
- Additional functional coverage and assertions.
- More extensive forwarding and hazard tests.
- FPGA-specific synthesis and resource analysis.
- Standard-cell technology mapping and static timing analysis.
- Power and physical area estimation using an appropriate implementation flow.

## Live Project Repository

GitHub repository:

https://github.com/vspranavkarthik/SiliconLite

Confirm that the repository is accessible before sharing this URL as the public project link.

## Conclusion

SiliconLite demonstrates the fundamentals of pipelined processor RTL design, data hazard handling, control hazard handling, simulation-based verification, and generic synthesis. The supplied verification transcript records a passing directed test, and the supplied Yosys log records successful generic synthesis and netlist generation.

The project provides a foundation for further processor verification and implementation-oriented work.