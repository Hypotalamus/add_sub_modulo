--------------------------------------------------------------------------------
-- Wrap sum din + delta_din to [min_value, max_value] range, where
-- - din - number in unsigned format, min_value <= din <= max_value;
-- - delta_din - number in signed format, din belongs to [- M/2, M/2) if
--      M is even, or [- (M - 1)/2, (M - 1)/2] if M is odd, and 
--      M = max_value - min_value + 1;
-- - dout - result (wrapped number) 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library add_sub_modulo_lib;
use add_sub_modulo_lib.constants_pkg.all;

entity add_sub_modulo is
    generic (
        DATA_WIDTH: positive := 8
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        din: in std_logic_vector(DATA_WIDTH - 1 downto 0);
        delta_din: in std_logic_vector(DATA_WIDTH - 1 downto 0);
        min_value: in std_logic_vector(DATA_WIDTH - 1 downto 0);
        max_value: in std_logic_vector(DATA_WIDTH - 1 downto 0);
        dout: out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity add_sub_modulo;

architecture rtl of add_sub_modulo is
    type data_delay_type is array(integer range <>) of unsigned(
        DATA_WIDTH - 1 downto 0);
    type modulo_delay_type is array(integer range <>) of unsigned(
        DATA_WIDTH downto 0);

    constant MIN_VALUE_DELAY: positive := MODULO_CALCULATOR_DELAY + 
        SIGNED_TO_MODULO_DELAY + ADD_MODULO_DELAY;

    signal modulo: unsigned(DATA_WIDTH downto 0);
    signal din_modulo_range: unsigned(DATA_WIDTH - 1 downto 0);
    signal delta_din_delay: signed(delta_din'range);
    signal delta_din_modulo: unsigned(DATA_WIDTH - 1 downto 0);
    signal din_modulo_range_delays: data_delay_type(1 to SIGNED_TO_MODULO_DELAY);
    signal modulo_delays: modulo_delay_type(1 to SIGNED_TO_MODULO_DELAY);
    signal sum_modulo: unsigned(DATA_WIDTH - 1 downto 0);
    signal min_value_delays: data_delay_type(1 to MIN_VALUE_DELAY);
begin

    modulo_calculator: process(clk) begin
        if rising_edge(clk) then
            if rst = '1' then
                modulo <= (others => '0');
            else
                modulo <= resize(unsigned(max_value), DATA_WIDTH + 1) -
                    resize(unsigned(min_value), DATA_WIDTH + 1) + 1;
            end if;
        end if;
    end process modulo_calculator;

    range_converter: process(clk) begin
        if rising_edge(clk) then
            if rst = '1' then
                din_modulo_range <= (others => '0');
            else
                din_modulo_range <= unsigned(din) - unsigned(min_value);
            end if;
        end if;
    end process range_converter;

    entity_delays: process(clk) begin
        if rising_edge(clk) then
            if rst = '1' then
                delta_din_delay <= (others => '0');
                din_modulo_range_delays <= (others => (others => '0'));
                modulo_delays <= (others => (others => '0'));
                min_value_delays <= (others => (others => '0'));                
            else
                delta_din_delay <= signed(delta_din);
                din_modulo_range_delays <= din_modulo_range & 
                    din_modulo_range_delays(din_modulo_range_delays'low to
                    din_modulo_range_delays'high - 1);
                modulo_delays <= modulo &  modulo_delays(modulo_delays'low to
                    modulo_delays'high - 1);
                min_value_delays <= unsigned(min_value) &
                    min_value_delays(min_value_delays'low to min_value_delays'high - 1);
            end if;
        end if;
    end process entity_delays;

    u_delta_din_converter: entity add_sub_modulo_lib.signed_to_modulo
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            signed_data => delta_din_delay,
            modulo => modulo,
            data_modulo => delta_din_modulo  
        );
        
    u_adder_mod: entity add_sub_modulo_lib.add_modulo
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            data_1 => din_modulo_range_delays(din_modulo_range_delays'high), 
            data_2 => delta_din_modulo, 
            modulo => modulo_delays(modulo_delays'high), 
            sum_out => sum_modulo
        );        

    range_back_converter: process(clk) begin
        if rising_edge(clk) then
            if rst = '1' then
                dout <= (others => '0');
            else
                dout <= std_logic_vector(sum_modulo + min_value_delays(min_value_delays'high));
            end if;
        end if;
    end process range_back_converter;

end architecture rtl;