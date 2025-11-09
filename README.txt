# Gray FIFO Design and Verification Project

## Overview
This project implements and verifies a Gray-coded FIFO in SystemVerilog.
It is intended for educational purposes to practice design and verification concepts.

## Simulation Environment
All simulation and verification for this project was developed and validated  
on EDA Playground, an online SystemVerilog/UVM environment.  

## Design Description
The FIFO is an design that uses Gray-coded pointers, read and write, to safely
synchronize data transfers between two clock domains.
A two-stage synchronizer is implemented for each pointer to ensure metastability mitigation.

### Main Features
- Parameterized data width and depth
- Gray code pointer conversion (binary <-> gray)
- Separate read and write clock domains
- Synchronization registers for cross-domain communication
- Full and empty flag generation

## Project Structure
```
design/      → RTL design files
tb/          → Testbench and verification files 
documents/   → Diagrams and wave examples
```

## Verification Environment
The verification is written in SystemVerilog using in UVM methodology.
The testbench includes:
- UVM components such as sequncer, driver, agent, interface etc.
- Stimulus generation for write and read interfaces
- Reference model for expected data behavior
- Scoreboard to compare DUT outputs against the reference

## Objectives
This project was created to:
1. Practice designing an asynchronous FIFO using Gray code.
2. Serve as a learning reference for UVM verification methodology.

## Future Improvements
- Implement coverage metrics for verification completeness.
- Add diagrams for the env structure.

## Author
Gadi Teicher
gadigidi@gmail.com
Electronics Engineer — Educational Verification Project
© 2025. All rights reserved
