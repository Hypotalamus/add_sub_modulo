onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /add_sub_modulo_tb/clk
add wave -noupdate /add_sub_modulo_tb/rst
add wave -noupdate -radix unsigned /add_sub_modulo_tb/din
add wave -noupdate -radix decimal /add_sub_modulo_tb/delta_din
add wave -noupdate -radix unsigned /add_sub_modulo_tb/min_value
add wave -noupdate -radix unsigned /add_sub_modulo_tb/max_value
add wave -noupdate -radix unsigned /add_sub_modulo_tb/dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 203
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ns} {210174 ns}
