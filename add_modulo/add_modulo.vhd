--------------------------------------------------------------------------------
-- Calculate sum_out = (data_1 + data_2) mod modulo
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_modulo is
    generic (
        DATA_WIDTH: positive := 16
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        data_1: in unsigned(DATA_WIDTH - 1 downto 0);
        data_2: in unsigned(DATA_WIDTH - 1 downto 0);
        modulo: in unsigned(DATA_WIDTH downto 0);
        sum_out: out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity add_modulo;

architecture rtl of add_modulo is
    signal unsigned_sum: unsigned(DATA_WIDTH - 1 downto 0);
    signal correction_term: unsigned(DATA_WIDTH - 1 downto 0);
    signal sum_with_correction: unsigned(DATA_WIDTH - 1 downto 0);
    signal sum_without_correction: unsigned(DATA_WIDTH - 1 downto 0);
    signal modulo_sum: unsigned(DATA_WIDTH - 1 downto 0);
    signal adder_1_carry_out: std_logic;
    signal adder_1_carry_out_delay: std_logic;
    signal adder_2_carry_out: std_logic;
begin

    adders: process(clk) 
        procedure add_with_carry_out(
            signal term_1: in unsigned(DATA_WIDTH - 1 downto 0);
            signal term_2: in unsigned(DATA_WIDTH - 1 downto 0);
            signal sum: out unsigned(DATA_WIDTH - 1 downto 0);
            signal carry_out: out std_logic
        ) is
            variable extended_sum: unsigned(DATA_WIDTH downto 0); 
        begin
            extended_sum := resize(term_1, DATA_WIDTH + 1) +
                resize(term_2, DATA_WIDTH + 1);
            sum <= resize(extended_sum, DATA_WIDTH);
            carry_out <= extended_sum(DATA_WIDTH);
        end procedure add_with_carry_out;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                unsigned_sum <= (others => '0');
                adder_1_carry_out <= '0';
                adder_1_carry_out_delay <= '0';
                sum_without_correction <= (others => '0');
                correction_term <= (others => '0');
                sum_with_correction <= (others =>'0');
                adder_1_carry_out <= '0';
            else
                add_with_carry_out(data_1, data_2, unsigned_sum, adder_1_carry_out);
                correction_term <= resize(2**DATA_WIDTH - modulo, DATA_WIDTH);
                sum_without_correction <= unsigned_sum;
                adder_1_carry_out_delay <= adder_1_carry_out;
                add_with_carry_out(unsigned_sum, correction_term, sum_with_correction,
                    adder_2_carry_out);
            end if;
        end if;
    end process adders;

    out_mux: process(clk) 
        variable mux_select: std_logic;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                modulo_sum <= (others => '0');
            else
                mux_select := adder_1_carry_out_delay or adder_2_carry_out;
                if mux_select = '1' then
                    modulo_sum <= sum_with_correction;
                else
                    modulo_sum <= sum_without_correction;
                end if;
            end if;
        end if;    
    end process out_mux;

    sum_out <= modulo_sum;

end architecture rtl;