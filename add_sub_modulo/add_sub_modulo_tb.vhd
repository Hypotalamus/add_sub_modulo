library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.all;

library add_sub_modulo_lib;

library sim_add_sub_modulo;
use sim_add_sub_modulo.sim_subprogramms_pkg.all;

entity add_sub_modulo_tb is
end entity add_sub_modulo_tb;

architecture sim of add_sub_modulo_tb is
    constant DATA_WIDTH: positive := 16;

    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal din: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal delta_din: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal min_value: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal max_value: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal dout: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');    
begin
    generate_clock(clk);
    generate_reset(rst);

    uut: entity add_sub_modulo_lib.add_sub_modulo
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            din => din,
            delta_din => delta_din,
            min_value => min_value,
            max_value => max_value,
            dout => dout
        );

    gen_data_in: process 
        file file_in : text open read_mode is "add_sub_modulo/test_input.txt";
        variable line_var : line;
        variable data_var, delta_var, min_value_var, max_value_var: integer;
    begin
        wait until not rst;
        wait_n_clk_falling_edge(clk, 5);

        while not endfile(file_in) loop
            readline(file_in, line_var);
            read(line_var, data_var);
            read(line_var, delta_var);
            read(line_var, min_value_var);
            read(line_var, max_value_var);

            din <= std_logic_vector(to_unsigned(data_var, din'length));
            delta_din <= std_logic_vector(to_signed(delta_var, delta_din'length));
            min_value <= std_logic_vector(to_unsigned(min_value_var, min_value'length));
            max_value <= std_logic_vector(to_unsigned(max_value_var, max_value'length));
            wait until not clk;
        end loop;
    end process gen_data_in;

    check_data_out: process
        file file_out: text open read_mode is "add_sub_modulo/test_output.txt"; 
        variable line_var: line;
        variable dout_var, sample_index: integer;
        variable index_suffix: string(1 to 2);
    begin
        wait until not rst;
        sample_index := 1;
        wait on dout;

        while not endfile(file_out) loop
            readline(file_out, line_var);

            -- Ignore empty strings in the end of file.            
            if line_var'length = 0 then
                report "Empty string at then end of file was found.";
                exit;
            end if;

            read(line_var, dout_var);

            index_suffix := set_index_suffix(sample_index);

            assert to_integer(unsigned(dout)) = dout_var
                report "Output of uut mismatch from reference: " &
                    integer'image(to_integer(unsigned(dout))) 
                    & " != " & integer'image(dout_var) &
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