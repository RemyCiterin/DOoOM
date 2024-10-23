{ pkgs ? import <nixpkgs> {} }:


pkgs.mkShell {
  buildInputs = [
    pkgs.libelf
    pkgs.bluespec
    pkgs.verilator
    pkgs.verilog
    pkgs.gtkwave
    pkgs.openfpgaloader
    pkgs.pkgsCross.riscv32-embedded.buildPackages.gcc
    pkgs.sail-riscv-rv64
    pkgs.qemu

    pkgs.yosys
    pkgs.nextpnrWithGui
    pkgs.trellis
    pkgs.icestorm

    pkgs.python312
    pkgs.python312Packages.matplotlib
    pkgs.python312Packages.pyserial
    pkgs.python312Packages.numpy

    pkgs.libelf

    pkgs.fujprog
  ];

  shellHook = ''
    export BLUESPECDIR=${pkgs.bluespec}/lib
    '';
}
