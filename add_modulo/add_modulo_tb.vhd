library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.all;

library add_sub_modulo_lib;

library sim_add_sub_modulo;
use sim_add_sub_modulo.sim_subprogramms_pkg.all;

entity add_modulo_tb is
end entity add_modulo_tb;

architecture sim of add_modulo_tb is
    constant DATA_WIDTH: natural := 8;

    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal data_1: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal data_2: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal modulo: unsigned(DATA_WIDTH downto 0) := (others => '0');
    signal sum_out: unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
begin
    generate_clock(clk);
    generate_reset(rst);

    uut: entity add_sub_modulo_lib.add_modulo
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            data_1 => data_1,
            data_2 => data_2,
            modulo => modulo,
            sum_out => sum_out
        );

    gen_data_in: process 
        file file_in : text open read_mode is "add_modulo/test_input.txt";
        variable line_var : line;
        variable data_1_var, data_2_var, modulo_var: integer;
    begin
        wait until not rst;
        wait_n_clk_falling_edge(clk, 5);

        while not endfile(file_in) loop
            readline(file_in, line_var);
            read(line_var, data_1_var);
            read(line_var, data_2_var);
            read(line_var, modulo_var);

            data_1 <= to_unsigned(data_1_var, data_1'length);
            data_2 <= to_unsigned(data_2_var, data_2'length);
            modulo <= to_unsigned(modulo_var, modulo'length);
            wait until not clk;
        end loop;
    end process gen_data_in;

    check_data_out: process
        file file_out: text open read_mode is "add_modulo/test_output.txt"; 
        variable line_var: line;
        variable sum_out_var, sample_index: integer;
        variable index_suffix: string(1 to 2);
    begin
        wait until not rst;
        sample_index := 1;
        wait on sum_out;

        while not endfile(file_out) loop
            readline(file_out, line_var);

            -- Ignore empty strings in the end of file.            
            if line_var'length = 0 then
                report "Empty string at then end of file was found.";
                exit;
            end if;
            
            read(line_var, sum_out_var);
            index_suffix := set_index_suffix(sample_index);

            assert to_integer(sum_out) = sum_out_var
                report "Output of uut mismatch from reference: " &
                    integer'image(to_integer(sum_out)) & " != " & integer'image(sum_out_var) &
                    " for " & integer'image(sample_index) & index_suffix & " sample index."
                severity failure;
            sample_index := sample_index + 1;
            wait_n_clk_rising_edge(clk, 1);
            wait_little_bit;
        end loop;

        print_test_ok;
        finish;
    end process check_data_out;

end architecture sim;