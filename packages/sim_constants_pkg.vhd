package sim_constants_pkg is
    constant SIM_CLOCK_FREQUENCY_Hz: real := 100.0e6;
    constant SIM_CLOCK_PERIOD: time := 1.0 / SIM_CLOCK_FREQUENCY_Hz * 1 sec;
    constant LITTLE_BIT_TIME: time := SIM_CLOCK_PERIOD / 10;
end package sim_constants_pkg;