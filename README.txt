# Gray FIFO Project - RTL Design and Verification

## Overview
This project implements and verifies a gray-coded FIFO.
It is intended for educational purposes to practice design and verification concepts.

## Simulation Environment
All simulation and verification for this project was developed and validated  
on EDA Playground, an online SystemVerilog/UVM environment.  

## Design Description
The FIFO is a design that uses gray-coded read and write pointers, to safely
synchronize data transfers between two clock domains.
A two-stage synchronizer is implemented for each pointer to ensure metastability mitigation.

### Main Features
- Separate read and write clock domains.
- Synchronization registers for cross-domain communication.
- Full and empty flag generation.

## Project Structure
design/      → RTL design files
tb/          → Testbench and verification files
documents/   → Diagrams and wave examples

## Verification Environment
The verification is written in SystemVerilog using UVM methodology.
The testbench includes:
- UVM components such as sequncer, driver, agent, interface etc.
- Stimulus generation for write and read interfaces.
- Reference model for expected data behavior.
- Scoreboard to compare DUT outputs against the reference.

## Future Improvments
- Solve verification issue: DUT non-deterministic behavior.
- Implement coverage metrics for verification completeness.
- Add diagrams for the env structure.

## Author
Gadi Teicher
gadigidi@gmail.com
© 2025. All rights reserved
