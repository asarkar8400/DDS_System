# Direct Digital Synthesis (DDS) System in VHDL

## 📜 Overview

This project implements a **Direct Digital Synthesis (DDS)** system in VHDL to generate sine waves with frequency selection using a phase accumulator and lookup table (LUT). This system was deployed onto a Lattice FPGA, validated on an oscilloscope, and includes a testbench for functional verification.

The system accepts a frequency control word (`freq_val`) and outputs an 8-bit sine wave (`dac_sine_value`), suitable for digital-to-analog conversion.

## 📐 DDS Output Frequency Formula

The output frequency is determined by:

\[
f_{\text{out}} = \frac{\text{freq\_val} \times f_{\text{clk}}}{2^{14}}
\]

Where:
- `freq_val` is a 14-bit tuning word (from switches)
- `f_clk` is the system clock (1 MHz in simulation)
- 14 is the width of the phase accumulator

---

## 🔧 Block Diagram and Component Descriptions

Below is a high-level description of each module in the DDS system:


### 🕹️ Switches
- 14-bit user input that sets the output sine wave frequency.
- Value is captured when the push button is pressed.

### 🔘 Push Button (PB)
- User-controlled input to load the new frequency setting.

### 🧠 Edge Detector FSM
- Detects the **rising edge** of the `load_freq` signal.
- Sends a 1-cycle pulse to load the new value into the Frequency Register.

### 📦 Frequency Register
- 14-bit register (`a = 14`).
- Stores the frequency control word from switches.
- Updated only on a rising edge of the `load_freq` signal.

### 🔁 Phase Accumulator
- Adds/subtracts the frequency word each clock cycle.
- Acts as the core of DDS by rolling over based on phase width.
- Top `m = 7` bits used to index the sine LUT.
- Generates `min` and `max` flags for FSM control.

### ⚙️ Phase Accumulator FSM
- Finite State Machine with 4 quadrants (Q1–Q4) representing sine wave segments.
- Controls direction (`up`) and half-cycle flag (`pos`).

### 📘 Sine Lookup Table (ROM)
- 128-entry table with unsigned quarter-cycle sine values (7-bit wide).
- Converts phase to sine amplitude for 1/4 cycle.
- Saves memory and leverages symmetry.

### ➕ Adder/Subtracter
- Uses `pos` flag to reflect sine value for negative half.
- Converts unsigned sine to signed 8-bit value centered around 128.
- Outputs final `dac_sine_value`.

### ⏱️ Clock and Reset
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
