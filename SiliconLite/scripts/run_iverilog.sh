#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
iverilog -g2005 -Wall -s tb_siliconlite_cpu -o build/siliconlite.vvp rtl/siliconlite_cpu.v tb/tb_siliconlite_cpu.v
vvp build/siliconlite.vvp | tee build/sim.log
grep -q 'RESULT: PASS' build/sim.log
