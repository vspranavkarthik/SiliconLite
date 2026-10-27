# Verification Plan

## Directed scenarios

1. ADDI initializes independent operands.
2. ADD depends on immediately preceding values, exercising forwarding.
3. SW followed by LW verifies word memory access.
4. ADDI immediately after LW checks load-use stall behavior.
5. BEQ taken verifies redirect and flush of the sequential instruction.
6. BNE taken verifies the alternate branch condition and flush.
7. AND, OR and SUB validate ALU function decoding.
8. A fixed-seed pseudo-random ADDI stream adds repeatable instruction activity in otherwise unused registers.

## Self-checks

The testbench checks x1-x11 and data-memory word 0 against expected values. It also checks that at least one load-use stall, two taken branches, and the expected instruction classes were observed. A failed check increments an error count and produces `RESULT: FAIL`.

## Functional coverage counters

Counters currently track observed R-type instructions, LW, SW, branch instructions, load-use stalls, taken branches, and total active cycles. These are lightweight directed functional indicators, not SystemVerilog covergroups and not a complete ISA coverage model. For a stronger submission, add bins for every supported ALU operation, branch taken/not-taken, forwarding source (EX/MEM and MEM/WB), stall/no-stall, destination x0 suppression, and dependency distances. Preserve the simulator transcript as the coverage evidence.

## Random test limitations

The random stream is fixed-seed and limited to ADDI instructions targeting x16-x23. It is repeatable but is not constrained-random verification of the complete ISA. For a more rigorous extension, generate legal instruction sequences from a software reference model and compare architectural register/memory state at a controlled retirement point.
