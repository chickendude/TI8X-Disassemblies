#!/bin/sh

ASM=spasm
EMU=tilem2

STATUS=0
# 0: Status good, assemble, check and emulate
# 1: Status bad, can't find assembler (spasm)
# 2: Status bad, can't run md5sum check
# 4: Status bad, can't find emulator

[ `which $ASM` ] && echo "Check for ${ASM}: Exists." || STATUS=`expr $STATUS + 1`
[ `which md5sum` ] && echo "Check for md5sum: Exists." || STATUS=`expr $STATUS + 2`
[ `which $EMU` ] && echo "Check for ${EMU}: Exists." || STATUS=`expr $STATUS + 4`
if [ $STATUS -gt "0" ]; then
    echo "The check came back with an error, exiting."
    echo "Status: $STATUS"
    exit $STATUS
else
    echo "All checks fine, assemble and emulate!"
fi

$ASM Cannon/cannon.asm Cannon/cannon.8xp -T -I inc
cd Cannon
md5sum -c cannon.md5
cd ..
sleep 1
$EMU Cannon/cannon.8xp
