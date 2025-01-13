-------------------------------------------------------------------------------
--
-- Title       : DDS_System
-- Design      : DDS System
-- Author      : aritro.sarkar9000@gmail.com
--
-------------------------------------------------------------------------------
--
-- File        : c:/My_Designs/Digital_Direct_Synthesis/DDS System/src/DDS_System.vhd
-- Generated   : Sun Jan 12 22:15:59 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity edge_det is
  port(
    rst_bar : in std_logic; -- asynchronous system reset
    clk : in std_logic; -- system clock
    sig : in std_logic; -- input signal
    pos : in std_logic; -- '1' for positive edge, '0' for negative
    sig_edge : out std_logic -- high for one sys. clk after edge
  );
end edge_det;

architecture moore_fsm of edge_det is
  type state is (initial, state0, state1, state01, state10);
  signal present_state, next_state : state;
begin

  state_reg: process (clk, rst_bar)
  begin
    if rst_bar = '0' then
      present_state <= initial;
    elsif rising_edge(clk) then
      present_state <= next_state;
    end if;
  end process;

  outputs: process (present_state)
  begin
    case present_state is
      when state01 => sig_edge <= '1';
      when state10 => sig_edge <= '1';
      when others => sig_edge <= '0';
    end case;
  end process;

  nxt_state: process (present_state, sig)
  begin
    case present_state is

      when initial => --initial state
        if sig = '0' then
          next_state <= state0;
        else
          next_state <= state1;
        end if;

      when state0 => --0 state
        if sig = '1' and pos = '1' then
          next_state <= state01;
        else
          next_state <= state0;
        end if;

      when state1 => --1 state
        if sig = '0' and pos = '0' then
          next_state <= state10;
        else
          next_state <= state1;
        end if;

      when state01 => --positive edge state
        if sig = '0' and pos = '0' then
          next_state <= state10;
        else
          next_state <= state1;
        end if;

      when state10 => --negative edge state
        if sig = '1' and pos = '1' then
          next_state <= state01;
        else
          next_state <= state0;
        end if;
    end case;
  end process;
end moore_fsm;
--------------------------------------Frequency Register--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity frequency_reg is
  generic (a : positive := 14);
  port(
    load : in std_logic; -- enable register to load data
    clk : in std_logic; -- system clock
    reset_bar : in std_logic; -- active low asynchronous reset
    d : in std_logic_vector(a-1 downto 0); -- data input
    q : out std_logic_vector(a-1 downto 0) -- register output
  );
end frequency_reg;

architecture behavioral of frequency_reg is
begin
  process (d, clk, load, reset_bar)
  begin
    if reset_bar = '0' then
      q <= "00000000000000";
    elsif rising_edge(clk) then
      if (load = '1') then
        q <= d;
      else
        null;
      end if;
    end if;
  end process;
end behavioral;

--------------------------------------Phase Accumulator--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity phase_accumulator is
  generic (
    a : positive := 14; -- width of phase accumulator
    m : positive := 7 -- width of phase accum output
  );
  port(
    clk : in std_logic; -- system clock
    reset_bar : in std_logic; -- asynchronous reset
    up : in std_logic; -- count direction control, 1 => up, 0 => dn
    d : in std_logic_vector(a - 1 downto 0); -- count delta
    max : out std_logic; -- count has reached max value
    min : out std_logic; -- count has reached min value
    q : out std_logic_vector(m - 1 downto 0) -- phase acc. output
  );
end phase_accumulator;

architecture behavioral of phase_accumulator is
begin
  process (clk, reset_bar, up, d)
    variable q_second : unsigned(a-1 downto 0);
  begin
    if reset_bar = '0' then
      q_second := (others => '0');
      min <= '1';
    elsif rising_edge(clk) then
      if up = '1' then
        q_second := q_second + unsigned(d);
      else
        q_second := q_second - unsigned(d);
      end if;

      if q_second = "00000000000000" or q_second - unsigned(d) - unsigned(d) > q_second then
        min <= '1';
      else
        min <= '0';
      end if;

      if q_second = 2**a - (unsigned(d)) or q_second + unsigned(d) + unsigned(d) < q_second then
        max <= '1';
      else
        max <= '0';
      end if;
    end if;
    q <= std_logic_vector(q_second(a - 1 downto m));
  end process;
end behavioral;	
--------------------------------------Phase Accumulator Finite State Machine--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity phase_accumulator_fsm is
  port(
    clk : in std_logic; -- system clock
    reset_bar : in std_logic; -- asynchronous reset
    max : in std_logic; -- max count
    min : in std_logic; -- min count
    up : out std_logic; -- count direction
    pos : out std_logic -- positive half of sine cycle
  );
end phase_accumulator_fsm;

architecture moore_fsm of phase_accumulator_fsm is
  type state is (quad1, quad2, quad3, quad4);
  signal present_state, next_state : state;
begin
  state_reg: process (clk, reset_bar)
  begin
    if reset_bar = '0' then
      present_state <= quad1;
    elsif rising_edge(clk) then
      present_state <= next_state;
    end if;
  end process;

  outputs: process (present_state)
  begin
    case present_state is
      when quad1 =>
        up <= '1';
        pos <= '1';
      when quad2 =>
        up <= '0';
        pos <= '1';
      when quad3 =>
        up <= '1';
        pos <= '0';
      when quad4 =>
        up <= '0';
        pos <= '0';
    end case;
  end process;

  nxt_state: process (present_state, min, max)
  begin
    case present_state is
      when quad1 =>
        if max = '1' then
          next_state <= quad2;
        else
          next_state <= quad1;
        end if;

      when quad2 =>
        if min = '1' then
          next_state <= quad3;
        else
          next_state <= quad2;
        end if;

      when quad3 =>
        if max = '1' then
          next_state <= quad4;
        else
          next_state <= quad3;
        end if;

      when quad4 =>
        if min = '1' then
          next_state <= quad1;
        else
          next_state <= quad4;
        end if;
    end case;
  end process;
end moore_fsm;
--------------------------------------Sine Table--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity sine_table is
  port(
    addr : in std_logic_vector(6 downto 0); -- table address
    sine_val : out std_logic_vector(6 downto 0) -- table entry value
  );
end sine_table;

architecture table of sine_table is
  type lut_type is array (0 to 127) of unsigned(6 downto 0);
  constant lut : lut_type := (
    "0000000", "0000001", "0000011", "0000100", "0000110", "0000111", "0001001", "0001010",
    "0001100", "0001101", "0001111", "0010001", "0010010", "0010100", "0010101", "0010111",
    "0011000", "0011010", "0011011", "0011101", "0011110", "0100000", "0100001", "0100011",
    "0100100", "0100110", "0100111", "0101001", "0101010", "0101100", "0101101", "0101111",
    "0110000", "0110010", "0110011", "0110100", "0110110", "0110111", "0111001", "0111010",
    "0111011", "0111101", "0111110", "0111111", "1000001", "1000010", "1000011", "1000101",
    "1000110", "1000111", "1001001", "1001010", "1001011", "1001100", "1001110", "1001111",
    "1010000", "1010001", "1010010", "1010100", "1010101", "1010110", "1010111", "1011000",
    "1011001", "1011010", "1011011", "1011101", "1011110", "1011111", "1100000", "1100001",
    "1100010", "1100011", "1100100", "1100101", "1100110", "1100110", "1100111", "1101000",
    "1101001", "1101010", "1101011", "1101100", "1101100", "1101101", "1101110", "1101111",
    "1110000", "1110000", "1110001", "1110010", "1110010", "1110011", "1110100", "1110100",
    "1110101", "1110101", "1110110", "1110111", "1110111", "1111000", "1111000", "1111001",
    "1111001", "1111001", "1111010", "1111010", "1111011", "1111011", "1111011", "1111100",
    "1111100", "1111100", "1111101", "1111101", "1111101", "1111101", "1111110", "1111110",
    "1111110", "1111110", "1111110", "1111110", "1111110", "1111110", "1111110", "1111111"
  );
begin
  sine_val <= std_logic_vector(lut(to_integer(unsigned(addr))));
end table;
--------------------------------------Adder Subtracter--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity adder_subtracter is
    port (
        pos : in std_logic;
        sine_value : in std_logic_vector(6 downto 0);
        dac_sine_val : out std_logic_vector(7 downto 0)
    );
end adder_subtracter;

architecture behavioral of adder_subtracter is
begin
    process(pos, sine_value)
        variable signed_output : unsigned(7 downto 0) := "10000000";
    begin
        if pos = '1' then -- positive half of cycle
            signed_output := unsigned('0' & sine_value) + 128; -- add 128 to sine value
        else -- negative half of cycle
            signed_output := 128 - unsigned('0' & sine_value); -- subtract 128 from sine value
        end if;

        dac_sine_val <= std_logic_vector(signed_output); -- convert output to std_logic_vector and assign to output port
    end process;
end behavioral;
--------------------------------------Structural Design--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity dds_w_freq_select is
    generic (a : positive := 14; m : positive := 7);
    port(
        clk : in std_logic; -- system clock
        reset_bar : in std_logic; -- asynchronous reset
        freq_val : in std_logic_vector(a - 1 downto 0); -- selects frequency
        load_freq : in std_logic; -- pulse to load a new frequency selection
        dac_sine_value : out std_logic_vector(7 downto 0); -- output to DAC
        pos_sine : out std_logic -- positive half of sine wave cycle
    );
end dds_w_freq_select;

architecture structural of dds_w_freq_select is
    signal pos : std_logic;
    signal sig_edge2 : std_logic;
    signal q_2 : std_logic_vector(13 downto 0);
    signal max : std_logic;
    signal min : std_logic;
    signal up : std_logic;
    signal sine_value : std_logic_vector(6 downto 0);
    signal addr : std_logic_vector(6 downto 0);
begin
    u1: entity edge_det port map(
        rst_bar => reset_bar,
        clk => clk,
        sig => load_freq,
        pos => '1',
        sig_edge => sig_edge2
    );

    u2: entity frequency_reg port map(
        load => sig_edge2,
        clk => clk,
        reset_bar => reset_bar,
        d => freq_val,
        q => q_2
    );

    u3: entity phase_accumulator port map(
        clk => clk,
        reset_bar => reset_bar,
        up => up,
        d => q_2,
        max => max,
        min => min,
        q => addr
    );

    u4: entity phase_accumulator_fsm port map(
        clk => clk,
        reset_bar => reset_bar,
        max => max,
        min => min,
        up => up,
        pos => pos
    );

    u5: entity sine_table port map(
        addr => addr,
        sine_val => sine_value
    );

    u6: entity adder_subtracter port map(
        pos => pos,
        sine_value => sine_value,
        dac_sine_val => dac_sine_value
    );

    pos_sine <= pos;
end structural;
