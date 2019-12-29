package constants_pkg is
    -- add_sub_modulo entity constants
    constant MODULO_CALCULATOR_DELAY: natural := 1;
    constant ADD_MODULO_DELAY: natural := 3;    
    constant SIGNED_TO_MODULO_DELAY: natural := 2;
    constant RANGE_BACK_DELAY: natural := 1;
    constant ADD_SUB_MODULO_DELAY: natural := MODULO_CALCULATOR_DELAY + 
        SIGNED_TO_MODULO_DELAY + ADD_MODULO_DELAY + RANGE_BACK_DELAY;
end package;