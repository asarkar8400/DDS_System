library ieee;
use ieee.std_logic_1164.all;
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
