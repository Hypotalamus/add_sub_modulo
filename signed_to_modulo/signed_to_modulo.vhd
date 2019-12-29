--------------------------------------------------------------------------------
-- Transform data_signed in range [-M/2, M/2) to data_modulo in [0, M) 
-- range, i.e. "data_signed mod data_modulo" operation.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_to_modulo is
    generic (
        DATA_WIDTH: positive := 8
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        signed_data: in signed(DATA_WIDTH - 1 downto 0);
        modulo: in unsigned(DATA_WIDTH downto 0);
        data_modulo: out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity signed_to_modulo;

architecture rtl of signed_to_modulo is
    signal corrected_data: unsigned(DATA_WIDTH - 1 downto 0);
    signal uncorrected_data: unsigned(DATA_WIDTH - 1 downto 0);
begin

    data_preprocessing: process(clk) begin
        if rising_edge(clk) then
            if rst = '1' then
                corrected_data <= (others => '0');
                uncorrected_data <= (others => '0');
            else
                uncorrected_data <= unsigned(signed_data);
                corrected_data <= resize(
                    resize(unsigned(signed_data), DATA_WIDTH + 1) + modulo, DATA_WIDTH);
            end if;
        end if;
    end process data_preprocessing;

    data_mux: process(clk) 
        function is_negative(x: unsigned) return boolean is begin
            if x(x'high) = '1' then
                return true;
            else
                return false;
            end if;
        end function is_negative;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                data_modulo <= (others => '0');
            else
                if is_negative(uncorrected_data) then
                    data_modulo <= corrected_data;
                else
                    data_modulo <= uncorrected_data;
                end if;
            end if;
        end if;
    end process data_mux;

end architecture rtl;