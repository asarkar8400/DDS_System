library IEEE;
use IEEE.std_logic_1164.all;
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
