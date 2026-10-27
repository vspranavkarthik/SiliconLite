# SiliconLite — Quality of Results (QoR) Report

## 1. Project Information

| Field | Details |
|---|---|
| Project | SiliconLite — 5-Stage Pipelined RISC Processor |
| RTL language | Verilog |
| Top module | `siliconlite_cpu` |
| Simulation tool | ModelSim Intel FPGA Edition 10.5b |
| Synthesis tool | Yosys 0.70+221 |
| Synthesis type | Generic logic synthesis |
| Report status | Based on the recorded simulation and synthesis logs |

## 2. Functional Verification Results

The recorded ModelSim transcript reports the following results.

| Metric | Recorded result |
|---|---:|
| Functional checks passed | 12 |
| Active cycles | 65 |
| Load-use stalls | 1 |
| Taken branches | 2 |
| Compilation/simulation errors | 0 |
| Simulation warnings | 0 |
| Final verification status | PASS |

### Verification Coverage

| Instruction class | Recorded count |
|---|---:|
| R-type | 4 |
| Load (`LW`) | 1 |
| Store (`SW`) | 1 |
| Branch | 2 |

These counts are the values printed by the testbench. They should not be interpreted as proof of exhaustive instruction coverage.

## 3. Generic Synthesis Results

The recorded Yosys synthesis log reports the following generic-cell statistics for `siliconlite_cpu`.

| Metric | Result |
|---|---:|
| Total generic cells | 112 |
| AND cells (`$_AND_`) | 49 |
| NOT cells (`$_NOT_`) | 1 |
| Synchronous-reset flip-flop cells (`$_SDFF_PP0_`) | 33 |
| XOR cells (`$_XOR_`) | 29 |
| Top-level ports | 5 |
| Top-level port bits | 67 |
| Wires | 336 |
| Wire bits | 8,983 |
| Generic Verilog netlist | `build/siliconlite_generic_netlist.v` |
| Synthesis log | `build/yosys.log` |

The listed cell counts sum to 112 generic cells.

## 4. Synthesis Flow

The synthesis script performs these operations:

1. Read the Verilog RTL.
2. Check the design hierarchy and top module.
3. Lower procedural logic.
4. Optimize the logic.
5. Process memory structures.
6. Map internal logic to generic cells.
7. Print synthesis statistics.
8. Write the generic Verilog netlist.

The recorded Yosys run completed and generated the netlist.

## 5. Physical Implementation Metrics

The following metrics have **not been measured** in the current project flow.

| Metric | Status |
|---|---|
| Technology-mapped cell area | Not measured |
| Core or die area | Not measured |
| Dynamic power | Not measured |
| Leakage power | Not measured |
| Critical path delay | Not measured |
| Setup slack | Not measured |
| Maximum operating frequency | Not measured |
| FPGA resource utilization | Not measured |

Generic-cell counts alone cannot establish physical area, power, timing, or maximum operating frequency.

## 6. Interpretation

The functional verification transcript reports a passing directed test with zero compilation/simulation errors and zero warnings. The testbench checks selected register and memory results and records load-use stalls, taken branches, and instruction-class counts.

The generic synthesis flow completed successfully and produced a netlist containing 112 generic cells. These results demonstrate functional verification of the tested scenarios and completion of a generic synthesis flow.

They do not establish complete ISA compliance, exhaustive verification, physical implementation quality, or timing closure.

## 7. Recommended Future QoR Work

To obtain implementation-oriented quality-of-results data:

1. Select a target FPGA device or standard-cell technology library.
2. Perform technology-specific synthesis or mapping.
3. Define clock and input/output timing constraints.
4. Run static timing analysis.
5. Estimate area using the selected technology.
6. Perform power estimation with suitable activity information and technology data.
7. Record tool versions, constraints, warnings, and reproducible logs.

All future results should be populated from actual tool outputs rather than estimated or invented values.

## 8. Reproducibility

Run functional simulation from the project directory:

```bat
vsim -c -do scripts\run_modelsim.do
```

Run generic synthesis with OSS CAD Suite configured:

```bat
yosys -l build\yosys.log -s scripts\synth_yosys.ys
```

Review the generated logs to confirm the results before publishing an updated report.

---

**Report conclusion:** SiliconLite has a passing directed ModelSim verification result and a completed Yosys generic synthesis result. Physical area, power, timing, and FPGA utilization remain unmeasured.