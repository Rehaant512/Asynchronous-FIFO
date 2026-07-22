# Parameterized Asynchronous FIFO

A robust, parameterized Asynchronous FIFO (First-In-First-Out) memory buffer written in Verilog. This project demonstrates Clock Domain Crossing (CDC) techniques to safely transfer data between two independent, asynchronous clock domains without data loss or metastability.

## System Architecture

The design is split into modular components separating the read domain, write domain, and memory array. 

<img width="1039" height="650" alt="Screenshot 2026-07-22 184958" src="https://github.com/user-attachments/assets/8a4e3e0b-b534-4bbc-9c31-1044e9962baf" />  



As shown in the block diagram above, the architecture relies on:
* **Central FIFO Memory:** A dual-port RAM block that handles simultaneous read and write operations.
* **Write Pointer Handler:** Operates on the write clock (`wclk`) and reset (`wrst_n`) to generate the `full` flag, manage the binary write pointer, and convert it to a Gray code pointer.
* **Read Pointer Handler:** Operates on the read clock (`rclk`) and reset (`rrst_n`) to generate the `empty` flag, manage the binary read pointer, and convert it to a Gray code pointer.
* **2-Stage Synchronizers:** Dual D-flip-flop synchronizers are used to safely cross the Gray-coded read and write pointers into their opposing clock domains to prevent multi-bit synchronization failures.

## Signal Definitions

The internal logic and module ports utilize the following key signals:

| Signal Name | Description |
| :--- | :--- |
| **`wr_en` / `rd_en`** | Write enable / Read enable |
| **`wr_data` / `rd_data`** | Write data bus / Read data bus |
| **`full` / `empty`** | FIFO is full flag / FIFO is empty flag |
| **`b_wptr` / `b_rptr`** | Binary write pointer / Binary read pointer |
| **`g_wptr` / `g_rptr`** | Gray write pointer / Gray read pointer |
| **`b_wptr_next` / `b_rptr_next`** | Binary write pointer next / Binary read pointer next |
| **`g_wptr_next` / `g_rptr_next`** | Gray write pointer next / Gray read pointer next |
| **`b_wptr_sync` / `b_rptr_sync`** | Binary write pointer synchronized / Binary read pointer synchronized |

##  Verification and Simulation

The design includes a comprehensive, self-checking SystemVerilog/Verilog testbench. It features asynchronous clock generation (50 MHz write, ~14.2 MHz read), staggered resets, and automated scoreboard checking.

### Waveform Analysis
The simulation proves First-Word Fall-Through (FWFT) timing, successful Gray code pointer synchronization across domains, and safe flag assertion to prevent overflows/underflows.

<img width="1551" height="650" alt="Screenshot 2026-07-22 184920" src="https://github.com/user-attachments/assets/10a81464-b17c-4c89-a270-cf7d68ef8e49" />



### Automated Checker Results
A dedicated verification monitor checks the data exactly as it exits the RAM, ensuring zero data corruption or misaligned reads. The testbench yields a 100% pass rate.

<img width="668" height="313" alt="Screenshot 2026-07-22 184937" src="https://github.com/user-attachments/assets/ebf36757-1af6-4082-8a0a-a09aed433eda" />

