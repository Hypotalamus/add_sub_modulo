onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /add_modulo_tb/clk
add wave -noupdate /add_modulo_tb/rst
add wave -noupdate -radix unsigned /add_modulo_tb/data_1
add wave -noupdate -radix unsigned /add_modulo_tb/data_2
add wave -noupdate -radix unsigned /add_modulo_tb/modulo
add wave -noupdate -radix unsigned /add_modulo_tb/sum_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 185
configure wave -valuecolwidth 76
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {21132 ns}
