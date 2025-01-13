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
