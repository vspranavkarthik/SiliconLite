# SiliconLite — 5-Stage RISC Core Design and Verification

A compact RV32I-subset processor in Verilog-2001. The design demonstrates IF, ID, EX, MEM and WB stages, ALU/register-file/control logic, EX/MEM and MEM/WB forwarding, load-use stalling, and branch redirection/flush.

## Scope and supported instructions

| Class | Instructions | Notes |
|---|---|---|
| R-type | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT` | `funct3`/`funct7` decoded in EX |
| I-type | `ADDI` | Sign-extended 12-bit immediate |
| Load/store | `LW`, `SW` | Word-aligned, 256-word data memory |
| Branch | `BEQ`, `BNE` | Branch decision in EX; taken branch flushes younger instructions |

This is an educational subset, not a complete RV32I implementation. It does not implement byte/halfword loads/stores, shifts, unsigned comparisons, JAL/JALR, exceptions, CSRs, interrupts, or misaligned access traps. Memory is modeled as arrays for simulation and must be mapped to a target memory implementation for physical FPGA/ASIC use.

## Repository

- `rtl/siliconlite_cpu.v` — synthesizable CPU RTL (Verilog-2001)
- `tb/tb_siliconlite_cpu.v` — directed self-checking testbench, fixed-seed pseudo-random ADDI stream, counters for instruction classes/stalls/branches
- `scripts/run_iverilog.sh` — compile and run with Icarus Verilog
- `scripts/run_modelsim.do` — ModelSim/Questa batch script
- `scripts/synth_yosys.ys` — Yosys synthesis script
- `scripts/run_yosys.sh` — synthesis runner
- `docs/verification_plan.md` — verification plan and coverage interpretation
- `docs/qor_template.md` — area/timing report template

## Run simulation

### Icarus Verilog

Install Icarus Verilog, then from this directory:

```bash
./scripts/run_iverilog.sh
```

Expected final line is `RESULT: PASS`. The script writes `build/sim.log` and `build/siliconlite.vvp`.

### ModelSim / Questa

From the project directory, run:

```tcl
vsim -c -do scripts/run_modelsim.do
```

If your installation uses a different executable path, launch `vsim` from its configured terminal or update PATH first.

## Run synthesis / QoR

Install Yosys. Run:

```bash
./scripts/run_yosys.sh
```

Review the final statistics and warnings. The script produces a generic synthesis netlist and reports cell statistics. Generic cell counts are not physical silicon area. For a defensible area/timing result, specify a target standard-cell library and constraints and run technology mapping plus static timing analysis (for example, OpenSTA with a compatible Liberty file and SDC). Fill in `docs/qor_template.md` only with measured results.

## Architecture notes

- `pc` and `imem` form the fetch path.
- IF/ID, ID/EX, EX/MEM and MEM/WB registers separate the five stages.
- Register x0 is hardwired to zero.
- Forwarding priority is EX/MEM (non-load result) then MEM/WB.
- A load-use dependency holds PC and IF/ID for one cycle and injects a bubble into ID/EX.
- A taken BEQ/BNE redirects PC and flushes IF/ID and ID/EX.
- Data memory uses word index `address[9:2]`; accesses are expected to be aligned.

## Important engineering note

Run the simulation and synthesis tools locally before claiming success. This delivery was generated without an HDL simulator or synthesis executable in the creation environment, so no actual tool run, coverage percentage, cell area, or timing number is asserted here. Resolve all tool warnings and failures before submission.
