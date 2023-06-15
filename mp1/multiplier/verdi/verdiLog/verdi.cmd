simSetSimulator "-vcssv" -exec "/home/davidm12/ece411/mp1/multiplier/sim/grading" \
           -args "+lint=all,noSVA-UA,noNS,noSVA-AECASR +v2k"
debImport "-dbdir" "/home/davidm12/ece411/mp1/multiplier/sim/grading.daidir"
debLoadSimResult /home/davidm12/ece411/mp1/multiplier/sim/dump.fsdb
wvCreateWindow
srcHBSelect "top.tb" -win $_nTrace1
srcHBSelect "top.tb" -win $_nTrace1
srcSetScope "top.tb" -delim "." -win $_nTrace1
srcHBSelect "top.tb" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 6 0 16 -win $_nTrace1 -name "add_shift_multiplier" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -signal "itf.clk" -line 8 -pos 1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -signal "itf.reset_n" -line 34 -pos 1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetWindowTimeUnit -win $_nWave2 10.000000 ns
wvSetCursor -win $_nWave2 13250.232748 -snap {("G2" 0)}
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -word -line 41 -pos 6 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcHBSelect "top.tb.dut.add" -win $_nTrace1
srcHBSelect "top.tb.dut.add" -win $_nTrace1
srcSetScope "top.tb.dut.add" -delim "." -win $_nTrace1
srcHBSelect "top.tb.dut.add" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -word -line 62 -pos 4 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "next.C" -line 67 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cur.Q\[0\]" -line 66 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cur" -line 64 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -signal "SHIFT" -line 65 -pos 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "next.op" -line 65 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "next" -line 64 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cur.A" -line 67 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcHBSelect "top.tb.dut" -win $_nTrace1
srcHBSelect "top.tb.dut" -win $_nTrace1
srcSetScope "top.tb.dut" -delim "." -win $_nTrace1
srcHBSelect "top.tb.dut" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk_i" -line 5 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "reset_n_i" -line 6 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "multiplicand_i" -line 7 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "ready_o" -line 10 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "start_i" -line 9 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "product_o" -line 11 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "ms" -line 16 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "done_o" -line 12 -pos 1 -win $_nTrace1
srcHBSelect "mult_types" -win $_nTrace1 -lib "work"
srcDeselectAll -win $_nTrace1
srcSelect -signal "product_o" -line 11 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "done_o" -line 12 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "ready_o" -line 10 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "done_o" -line 12 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "ready_o" -line 10 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "start_i" -line 9 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
debExit
