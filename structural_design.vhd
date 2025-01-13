library ieee;
use ieee.std_logic_1164.all;
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

    u6: entity adder_subtractor port map(
        pos => pos,
        sine_value => sine_value,
        dac_sine_val => dac_sine_value
    );

    pos_sine <= pos;
end structural;
