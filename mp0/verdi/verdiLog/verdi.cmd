simSetSimulator "-vcssv" -exec "/home/davidm12/ece411/mp0/sim/simv" -args \
           "+lint=all"
debImport "-dbdir" "/home/davidm12/ece411/mp0/sim/simv.daidir"
debLoadSimResult /home/davidm12/ece411/mp0/sim/dump.fsdb
wvCreateWindow
srcHBSelect "mp0_tb.mp0.rf.unnamed\$\$_0" -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf.unnamed\$\$_0" -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf.unnamed\$\$_0" -win $_nTrace1
srcSetScope "mp0_tb.mp0.rf.unnamed\$\$_0" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf.unnamed\$\$_0" -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf" -win $_nTrace1
srcSetScope "mp0_tb.mp0.rf" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf" -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf" -win $_nTrace1
srcSetScope "mp0_tb.mp0.rf" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf" -win $_nTrace1
wvSelectGroup -win $_nWave2 {G1}
srcDeselectAll -win $_nTrace1
srcSelect -signal "reg_a" -line 13 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 1290.703496 -snap {("G2" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "data\[dest\]" -line 23 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "load" -line 22 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dest" -line 22 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcHBSelect "mp0_tb.mp0.rf.unnamed\$\$_0" -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf" -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf.unnamed\$\$_0" -win $_nTrace1
srcSetScope "mp0_tb.mp0.rf.unnamed\$\$_0" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf.unnamed\$\$_0" -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf" -win $_nTrace1
srcSetScope "mp0_tb.mp0.rf" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "src_a" -line 6 -pos 1 -win $_nTrace1
srcAction -pos 5 11 2 -win $_nTrace1 -name "src_a" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "src_a" -line 9 -pos 1 -win $_nTrace1
srcAction -pos 8 8 2 -win $_nTrace1 -name "src_a" -ctrlKey off
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "src_b" -line 9 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "reg_a" -line 8 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "reg_b" -line 8 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dest" -line 9 -pos 1 -win $_nTrace1
srcHBSelect "mp0_tb.print_reg" -win $_nTrace1
srcHBSelect "mp0_tb.print_reg" -win $_nTrace1
srcSetScope "mp0_tb.print_reg" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.print_reg" -win $_nTrace1
srcHBSelect "mp0_tb.print_reg" -win $_nTrace1
srcHBSelect "mp0_tb.print_regfile" -win $_nTrace1
srcSetScope "mp0_tb.print_regfile" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.print_regfile" -win $_nTrace1
srcHBSelect "mp0_tb.regfile_write" -win $_nTrace1
srcSetScope "mp0_tb.regfile_write" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.regfile_write" -win $_nTrace1
srcHBSelect "mp0_tb.reset" -win $_nTrace1
srcSetScope "mp0_tb.reset" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.reset" -win $_nTrace1
srcHBSelect "mp0_tb.sequential_write" -win $_nTrace1
srcSetScope "mp0_tb.sequential_write" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.sequential_write" -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf.unnamed\$\$_0" -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf" -win $_nTrace1
srcSetScope "mp0_tb.mp0.rf" -delim "." -win $_nTrace1
srcHBSelect "mp0_tb.mp0.rf" -win $_nTrace1
debExit
