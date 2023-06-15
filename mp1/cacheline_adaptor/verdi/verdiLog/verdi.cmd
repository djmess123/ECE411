simSetSimulator "-vcssv" -exec \
           "/home/davidm12/ece411/mp1/cacheline_adaptor/sim/simv" -args \
           "+lint=all,noSVA-UA,noNS,noSVA-AECASR,noSVA-FINUA +v2k"
debImport "-dbdir" "/home/davidm12/ece411/mp1/cacheline_adaptor/sim/simv.daidir"
debLoadSimResult /home/davidm12/ece411/mp1/cacheline_adaptor/sim/dump.fsdb
wvCreateWindow
srcDeselectAll -win $_nTrace1
srcHBSelect "testbench.dut" -win $_nTrace1
srcSetScope "testbench.dut" -delim "." -win $_nTrace1
srcHBSelect "testbench.dut" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 3 -pos 1 -win $_nTrace1
srcSelect -signal "reset_n" -line 4 -pos 1 -win $_nTrace1
srcSelect -signal "line_i" -line 7 -pos 1 -win $_nTrace1
srcSelect -signal "line_o" -line 8 -pos 1 -win $_nTrace1
srcSelect -signal "address_i" -line 9 -pos 1 -win $_nTrace1
srcSelect -signal "read_i" -line 10 -pos 1 -win $_nTrace1
srcSelect -signal "write_i" -line 11 -pos 1 -win $_nTrace1
srcSelect -signal "resp_o" -line 12 -pos 1 -win $_nTrace1
srcSelect -signal "burst_i" -line 15 -pos 1 -win $_nTrace1
srcSelect -signal "burst_o" -line 16 -pos 1 -win $_nTrace1
srcSelect -signal "address_o" -line 17 -pos 1 -win $_nTrace1
srcSelect -signal "read_o" -line 18 -pos 1 -win $_nTrace1
srcSelect -signal "write_o" -line 19 -pos 1 -win $_nTrace1
srcSelect -signal "resp_i" -line 20 -pos 1 -win $_nTrace1
srcSelect -signal "buffer" -line 24 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetWindowTimeUnit -win $_nWave2 10.000000 us
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
debExit
