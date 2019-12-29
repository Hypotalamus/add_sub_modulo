library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;

library sim_add_sub_modulo;
use sim_add_sub_modulo.sim_constants_pkg.all;

package sim_subprogramms_pkg is
    procedure generate_clock(signal clk: inout std_logic);

    procedure generate_reset(signal rst: out std_logic);

    procedure wait_n_clk_rising_edge(
        signal clk: in std_logic;
        n: positive
    );

    -- Wait small amount of time to settle all transitions between delta cycles.
    procedure wait_little_bit;

    procedure wait_n_clk_falling_edge(
        signal clk: in std_logic;
        n: positive
    );

    procedure print_test_ok;

    function set_index_suffix(index: integer) return string;

end package sim_subprogramms_pkg;

package body sim_subprogramms_pkg is
    procedure generate_clock(signal clk: inout std_logic) is begin
        clk <= not clk after SIM_CLOCK_PERIOD / 2;
    end procedure generate_clock;

    procedure generate_reset(signal rst: out std_logic) is begin
        rst <= '1', '0' after 5 * SIM_CLOCK_PERIOD;
    end procedure generate_reset;

    procedure wait_n_clk_rising_edge(
        signal clk: in std_logic;
        n: positive
    ) is begin
        for ii in 0 to n - 1 loop
            wait until clk;
        end loop;
    end procedure wait_n_clk_rising_edge;

    procedure wait_n_clk_falling_edge(
        signal clk: in std_logic;
        n: positive
    ) is begin
        for ii in 0 to n - 1 loop
            wait until not clk;
        end loop;
    end procedure wait_n_clk_falling_edge;

    procedure wait_little_bit is begin
        wait for LITTLE_BIT_TIME;
    end procedure wait_little_bit;

    procedure print_test_ok is 
        variable my_line: line;
    begin
        write(my_line, string'("Test passed."));
        writeline(output, my_line);
    end procedure print_test_ok;

    function set_index_suffix(index: integer) return string is begin
        if index > 3 then
            return "th";
        elsif index = 3 then
            return "rd";
        elsif index = 2 then
            return "nd";
        elsif index = 1 then
            return "st";
        else
            assert False report "Error! Index must be > 0!" severity failure;
            return "XX";
        end if;
    end function set_index_suffix;

end package body sim_subprogramms_pkg;