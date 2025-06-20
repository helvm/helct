#!/usr/bin/env bash

mkdir_and_cp() {
  mkdir -p $(dirname "$2") && cp -rf "$1" "$2"
}

mkdir_and_cp dist-newstyle/build/*/*/*/doc/html/helct/ docs/reports/helct/
#mkdir_and_cp dist-newstyle/build/*/*/*/t/helct-test/hpc/vanilla/html/ docs/reports/helct-test/
