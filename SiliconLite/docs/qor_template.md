# Synthesis Quality-of-Results (QoR) Report

## Tool and target
- RTL revision/date:
- Synthesis tool/version:
- Target library/process corner:
- Clock target and constraints (SDC):
- Mapping and timing tools:

## Area
| Metric | Measured value | Source report |
|---|---:|---|
| Generic logic cells (Yosys `stat`) | Fill after run | `build/yosys.log` |
| Mapped cell area (library units) | Not measured until mapped | Technology-mapped synthesis report |
| Sequential cell count | Fill after run | Synthesis report |

## Timing
| Metric | Measured value | Source report |
|---|---:|---|
| Clock period constraint | Fill in | SDC |
| Worst setup slack | Not measured until STA | OpenSTA/vendor STA report |
| Critical path startpoint/endpoint | Not measured until STA | Timing report |
| Estimated maximum frequency | Derive only from valid timing result | STA report |

## Analysis
Document the actual critical path, its logic contributors, and realistic optimization options. Candidate areas to inspect include branch compare/redirect, ALU decode/result logic, register-file muxing, and memory implementation. Do not present generic cell count as physical area or infer a clock frequency without timing constraints and a timing report.
