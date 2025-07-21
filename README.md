# Direct Digital Synthesis (DDS) System in VHDL

## 📜 Overview

This project implements a **Direct Digital Synthesis (DDS)** system in VHDL to generate sine waves with frequency selection using a phase accumulator and lookup table (LUT). This system was deployed onto a Lattice FPGA, validated on an oscilloscope, and includes a testbench for functional verification.

<img width="1697" height="555" alt="dds_screenshot" src="https://github.com/user-attachments/assets/6137a98d-f530-480c-b986-f862b4504a91" />
*[DDS Generated 40kHz Waveform]*

The system accepts a frequency control word (`freq_val`) and outputs an 8-bit sine wave (`dac_sine_value`), suitable for digital-to-analog conversion.

## DDS Output Frequency Formula

The output frequency is determined by:

<img width="116" height="58" alt="image" src="https://github.com/user-attachments/assets/d3d75ea5-4c0d-4cf0-97ca-358f539fbbae" />

Where:
- `freq_val` is a 14-bit tuning word (from switches)
- `f_clk` is the system clock (1 MHz in simulation)
- 14 is the width of the phase accumulator

---

## Block Diagram and Component Descriptions
<img width="1321" height="322" alt="image" src="https://github.com/user-attachments/assets/c13d77af-681f-490f-bb23-1e6ed7cd60c9" />

### Edge Detector FSM
<img width="522" height="495" alt="image" src="https://github.com/user-attachments/assets/4ad92a71-9e69-4077-9716-d85cce1f8dfb" />

- Detects the **rising edge** of the `load_freq` signal.
- Sends a 1-cycle pulse to load the new value into the Frequency Register.

### Frequency Register
- 14-bit register (`a = 14`).
- Stores the frequency control word from switches.
- Updated only on a rising edge of the `load_freq` signal.

### Phase Accumulator
- Adds/subtracts the frequency word each clock cycle.
- Acts as the core of DDS by rolling over based on phase width.
- Top `m = 7` bits used to index the sine LUT.
- Generates `min` and `max` flags for FSM control.

### Phase Accumulator FSM
<img width="475" height="528" alt="image" src="https://github.com/user-attachments/assets/15745515-ff31-4816-b4f6-4a295853ad5b" />
- Finite State Machine with 4 quadrants (Q1–Q4) representing sine wave segments.
- Controls direction (`up`) and half-cycle flag (`pos`).

### Sine Lookup Table
- 128-entry table with unsigned quarter-cycle sine values (7-bit wide).
- Converts phase to sine amplitude for 1/4 cycle.
- Saves memory and leverages symmetry.

### Adder/Subtracter
- Uses `pos` flag to reflect sine value for negative half.
- Converts unsigned sine to signed 8-bit value centered around 128.
- Outputs final `dac_sine_value`.

## Testbench
The testbench:
- Drives the system clock at `1 MHz`
- Pulses `load_freq` to reload value into `freq_val`
- Reset is active-low asynchronous
- Sets `freq_val` using a 14-bit signal 
- Observes the resulting `dac_sine_value`.
- 
---
## Implementation on Hardware
The system was sythesized onto a Lattice FPGA and the register containing `dac_sine_value` is passed through a DAC, followed by a low pass filter (LPF). The output was then validated on an oscilloscope and used switches as input to set the output sine wave frequency dynamically, and a push button to trigger frequency loading.
