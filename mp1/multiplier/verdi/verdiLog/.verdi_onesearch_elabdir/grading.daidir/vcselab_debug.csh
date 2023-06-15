#!/bin/csh -f

cd /home/davidm12/ece411/mp1/multiplier/sim

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/software/Synopsys-2021_x86_64/vcs/R-2020.12-SP1-1/linux64/bin/vcselab $* \
    -o \
    grading \
    -nobanner \

cd -

