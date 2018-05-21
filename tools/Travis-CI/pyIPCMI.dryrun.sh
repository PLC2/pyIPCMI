#! /usr/bin/env bash

# define color escape codes
RED='\e[0;31m'			# Red
GREEN='\e[1;32m'		# Green
YELLOW='\e[1;33m'		# Yellow
MAGENTA='\e[1;35m'		# Magenta
CYAN='\e[1;36m'			# Cyan
NOCOLOR='\e[0m'			# No Color

pyIPCMIROOT=$(pwd)

TRAVIS_DIR=$pyIPCMIROOT/tools/Travis-CI

# -> LastExitCode
# -> Error message
ExitIfError() {
	if [ $1 -ne 0 ]; then
		echo 1>&2 -e $2
		# Cleanup and exit
		exec 1>&-
		wait # for output filter
		exit 1
	fi
}
# -> LastExitCode
# -> Error message
ExitIfNoError() {
	if [ $1 -eq 0 ]; then
		echo 1>&2 -e $2
		# Cleanup and exit
		exec 1>&-
		wait # for output filter
		exit 1
	fi
}



echo -e "${MAGENTA}========================================${NOCOLOR}"
echo -e "${MAGENTA}  Running pyIPCMI in dryrun mode        ${NOCOLOR}"
echo -e "${MAGENTA}========================================${NOCOLOR}"

# Check if output filter grcat is available and install it
if grcat $TRAVIS_DIR/pyIPCMI.grcrules</dev/null 2>/dev/null; then
	echo -e "Pipe STDOUT through grcat ..."
	{ coproc grcat $TRAVIS_DIR/pyIPCMI.grcrules 1>&3; } 3>&1
  exec 1>&${COPROC[1]}-
fi

echo -e "Testing Active-HDL (1/5)..."
$pyIPCMIROOT/pyIPCMI.sh --dryrun asim "pyIPCMI.arith.prng"
ExitIfNoError $? "${RED}Testing Active-HDL [FAILED]${NOCOLOR}"

echo -e "Testing Riviera-PRO (2/5)..."
$pyIPCMIROOT/pyIPCMI.sh --dryrun rpro "pyIPCMI.arith.prng"
ExitIfError $? "${RED}Testing Riviera-PRO [FAILED]${NOCOLOR}"

echo -e "Testing GHDL (3/6)..."
$pyIPCMIROOT/pyIPCMI.sh --dryrun ghdl "pyIPCMI.arith.prng"
ExitIfError $? "${RED}Testing ModelSim [FAILED]${NOCOLOR}"

echo -e "Testing ModelSim (4/6)..."
$pyIPCMIROOT/pyIPCMI.sh --dryrun vsim "pyIPCMI.arith.prng"
ExitIfError $? "${RED}Testing ModelSim [FAILED]${NOCOLOR}"

echo -e "Testing ISE Simulator (5/6)..."
$pyIPCMIROOT/pyIPCMI.sh --dryrun isim "pyIPCMI.arith.prng"
ExitIfError $? "${RED}Testing ISE Simulator [FAILED]${NOCOLOR}"

echo -e "Testing Vivado Simulator (6/6)..."
$pyIPCMIROOT/pyIPCMI.sh --dryrun xsim "pyIPCMI.arith.prng"
ExitIfError $? "${RED}Testing Vivado Simulator [FAILED]${NOCOLOR}"

$ret=0

# Cleanup and exit
exec 1>&-
wait # for output filter
exit $ret
