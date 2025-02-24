#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")"

DOTNET_EXE=dotnet.exe
PAKET_EXE=$DOTNET_EXE paket
FAKE_EXE=packages/build/FAKE/tools/FAKE.exe

FSIARGS=""
FSIARGS2=""
OS=${OS:-"unknown"}
if [ "$OS" != "Windows_NT" ]
then
  # Can't use FSIARGS="--fsiargs -d:MONO" in zsh, so split it up
  # (Can't use arrays since dash can't handle them)
  FSIARGS="--fsiargs"
  FSIARGS2="-d:MONO"
fi

run() {
  if [ "$OS" != "Windows_NT" ]
  then
    echo "Running on linux/macs => using Mono"
    mono "$@"
  else
    "$@"
  fi
}

echo "Executing Dotnet..."
run $DOTNET_EXE tool restore

echo "Executing Paket..."

FILE='paket.lock'     
if [ -f $FILE ]; then
   echo "paket.lock file found, restoring packages..."
   run $PAKET_EXE restore
else
   echo "paket.lock was not found, installing packages..."
   run $PAKET_EXE install
fi

echo "Executing FAKE..."

run $FAKE_EXE "$@" $FSIARGS $FSIARGS2 build.fsx
