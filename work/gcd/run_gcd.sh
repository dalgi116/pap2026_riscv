TEST_NAME=gcd

echo "RTL compilation using QuestaSim..."
vlog -work qsim ../../rtl/*.v ../../tb/*.sv || exit 1

echo "Running simulation..."
RESULT=$(vsim -c -do "run -all; quit -f" qsim.tb_riscv +FIRMWARE=../../sw/$TEST_NAME.dat +TEST=$TEST_NAME)

if echo "$RESULT" | grep -q "PASS$"  ; then
    echo "$TESTNAME: PASS"
else
    echo "$TESTNAME: FAIL"
fi