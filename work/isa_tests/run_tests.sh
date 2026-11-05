#!/bin/env bash

# The template to build and run the RISC-V official tests on own CPU design
#
# The initial motivation is to help studnets of
# the B4M35PAP - Advanced Computer Architectures course
# https://cw.fel.cvut.cz/wiki/courses/b4m35pap/start
#
# The related Czech technical University in Prague courses guidepost
# https://comparch.edu.cvut.cz/
#
# (C) 2025 Karel Bartunek and Pavel Pisa as public domain

if [ ! -e riscv-tests ]; then
    echo "Downloading official RISC-V tests"
    echo "In the case of problems, switch to 6b474726f51d9ed909b467be0390a6f3d04527f1 version."
    git clone https://github.com/riscv-software-src/riscv-tests riscv-tests
    cd riscv-tests
    git checkout 6b474726f51d9ed909b467be0390a6f3d04527f1
    git submodule update --init --recursive
    cd ..
fi

if [ ! -e riscv-tests/env/p/link.ld ] ; then
  echo "Creating symlinks from test-env"
  mkdir -p riscv-tests/env/p
  ln -sf ../../../test-env/link.ld riscv-tests/env/p
  ln -sf ../../../test-env/riscv_test.h riscv-tests/env/p
  ln -sf ../../../test-env/encoding.h riscv-tests/env/p
fi

# Rebuild is mandatory
if [ -e riscv-tests/isa ] ; then
  echo "Obtaining a list of useful rv32-ui tests"
  TARGETS=$(make -C riscv-tests/isa clean 2>&1 | tr ' ' '\n' | grep .dump | sed -n -e "s/^\(rv32u[i].*-p-.*\)/\1/p" | tr "\n" " " )
else
  echo "riscv-tests has not successfully been cloned into 'riscv-tests'."
  exit 2
fi

# Design compilation
echo "RTL compilation using QuestaSim..."
vlog -work qsim ../../rtl/*.v ../../tb/*.sv || exit 1

# Compile test binaries
make -C riscv-tests/isa $TARGETS 1>/dev/null || exit 1

# Iterate over built targets
echo $targetlist
for TESTFILENAME in $TARGETS; do
    TESTNAME="${TESTFILENAME%.dump}"
    # Convert ELF to a sequence of instructions (.bin)
    riscv64-unknown-elf-objcopy --strip-debug -O binary riscv-tests/isa/$TESTNAME riscv-tests/isa/$TESTNAME.bin || exit 1
    riscv64-unknown-elf-objcopy --strip-debug -O verilog --verilog-data-width 4 riscv-tests/isa/$TESTNAME riscv-tests/isa/$TESTNAME.vdat || exit 1
    # To Verilog format
    hexdump -v -e '"%08x\n" ' riscv-tests/isa/$TESTNAME.bin > riscv-tests/isa/$TESTNAME.dat

    TEST_FILE=riscv-tests/isa/$TESTNAME.dat
    
    echo "Executing with memory in $TEST_FILE"
    RESULT=$(vsim -c -do "run -all; quit -f" qsim.tb_riscv +FIRMWARE=$TEST_FILE +TEST=isa)

    if echo "$RESULT" | grep -q "PASS$"  ; then
        echo "$TESTNAME: PASS"
    else
        echo "$TESTNAME: FAIL"
    fi
done
