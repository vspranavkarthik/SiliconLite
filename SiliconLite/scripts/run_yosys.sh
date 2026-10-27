#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
yosys -s scripts/synth_yosys.ys 2>&1 | tee build/yosys.log
