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
