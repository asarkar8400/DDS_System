# Direct Digital Synthesis (DDS) System in VHDL

## 📜 Overview

This project implements a **Direct Digital Synthesis (DDS)** system in VHDL to generate sine waves with frequency selection using a phase accumulator and lookup table (LUT). This system was deployed onto a Lattice FPGA, validated on an oscilloscope, and includes a testbench for functional verification.

The system accepts a frequency control word (`freq_val`) and outputs an 8-bit sine wave (`dac_sine_value`), suitable for digital-to-analog conversion.

## 📐 DDS Output Frequency Formula

The output frequency is determined by:

<img width="122" height="67" alt="image" src="https://github.com/user-attachments/assets/073de0d5-f1b9-44e6-94be-2bd0bdc257da" />

Where:
- `freq_val` is a 14-bit tuning word (from switches)
- `f_clk` is the system clock (1 MHz in simulation)
- 14 is the width of the phase accumulator

---

## 🔧 Block Diagram and Component Descriptions
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
![Uploading image.png…]()

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

### Clock and Reset
- `clk`: System clock, typically 1 MHz in simulation.
- `reset_bar`: Active-low asynchronous reset.

---

## 🧪 Testbench

The testbench:
- Drives the system clock (`1 MHz`).
- Pulses `reset_bar` and `load_freq` at specific times.
- Sets `freq_val` using a 14-bit signal (e.g., 656 for ~40 kHz output).
- Observes the resulting `dac_sine_value`.

```vhdl
-- Example freq_val setting:
freq_val <= "00001010010000"; -- Decimal 656 = ~40 kHz output
