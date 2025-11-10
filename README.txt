# Gray FIFO Project - RTL Design and Verification

## Overview
This project implements and verifies a gray-coded FIFO.
It is intended for educational purposes to practice design and verification concepts.

## Simulation Environment
All simulation and verification for this project was developed and simulated  
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
- UVM components such as sequencer, driver, agent, interface etc.
- Stimulus generation for write and read interfaces.
- Reference model for expected data behavior.
- Scoreboard to compare DUT outputs against the reference.

## Future Improvements
- Resolve verification issue: DUT non-deterministic behavior.
- Split the current agent (which wraps separate driver/monitor/sequencer components 
  for the write and read sides) into 2 independent agents.
- Implement functional coverage metrics for verification completeness.
- Add block and architecture diagrams to illustrate the environment structure.

## Author
Gadi Teicher
gadigidi@gmail.com
© 2025. All rights reserved
