library ieee;
use ieee.std_logic_1164.all;
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
