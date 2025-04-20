# EE2026 FPGA Design Project (FDP)

## Team Members (S2_07)

*   [CHENG JIA WEI ANDY](https://github.com/averageandyyy)
*   [CHOY WAYNE](https://github.com/WayneCh0y)
*   [DANIEL KWAN](https://github.com/danielkwan2004)
*   [HO WEI HAO](https://github.com/HoWeiHao)

## Project Overview

This repository contains the files for an FPGA design project, developed for the EE2026 course. The project implements a graphing calculator on a Xilinx Artix-7 FPGA.

### Functionality

The calculator is capable of:

*   **Fixed-Point Arithmetic:** Performs calculations using Q16.16 fixed-point number representation.
*   **Polynomial Graphing:** Graphs polynomial equations up to degree 3 (e.g., `y = ax^3 + bx^2 + cx + d`).
*   **Graph Interaction:** Allows users to zoom in/out and pan the graph view for better visualization.
*   **Table of Values:** Generates and displays a table of (x, y) values based on the entered polynomial equation.
*   **Integral Calculation:** Computes the definite integral of the polynomial between user-specified lower and upper bounds.
*   **Integral Shading:** Visually represents the calculated integral by shading the corresponding area under the curve on the graph.

## Hardware and Software

*   **FPGA:** Xilinx Artix-7 (Device: `xc7a35tcpg236-1`)
*   **Software:** Xilinx Vivado 2018.2

## Setup and Build

1.  Ensure you have Xilinx Vivado 2018.2 installed.
2.  Open the project file: [`FDP.xpr`](c:\andy\EE2026-FPGA-Design-Project\FDP.xpr) in Vivado.
3.  Run Synthesis: Use the `synth_1` run configuration.
4.  Run Implementation: Use the `impl_1` run configuration.
5.  Generate Bitstream.
6.  Program the target FPGA device using the generated bitstream.

## Directory Structure

*   `.gitignore`: Specifies intentionally untracked files by Git.
*   `FDP.xpr`: Vivado project file.
*   `FDP.srcs/`: Contains project source files (Verilog, IP cores, constraints).
    *   `sources_1/`: HDL source files, imported files, and IP configurations.
    *   `constrs_1/`: Constraint files (e.g., `.xdc`).
    *   `sim_1/`: Simulation source files.
*   `FDP.runs/`: Stores output files from synthesis and implementation runs.
*   `*.pdf`: User Guide and Report.
*   `archive_project_summary.txt`: Summary of archived project contents.

## Usage

Refer to the User Guide PDF ([`S2_07_CHENG JIA_CHOY WAYNE_DANIEL KWAN_HO WEI_User_Guide_ReportPersonal and Team Improvement.pdf`](https://github.com/averageandyyy/EE2026-FPGA-Design-Project/blob/reversion-changes/S2_07_CHENG%20JIA_CHOY%20WAYNE_DANIEL%20KWAN_HO%20WEI_User_Guide_ReportPersonal%20and%20Team%20Improvement.pdf)) for detailed instructions on how to operate the graphing calculator, including entering equations, setting bounds, and using the zoom/pan features.