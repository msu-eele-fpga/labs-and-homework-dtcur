
# Homework 7: Linux CLI Practice

## Overview
Using some common string manipulation Linux CLI commands. 

## Deliverables

###
> 'wc -w lorem-ipsum.txt'
![Problem 1](assets/hw-7/LoreIpsumWordCount.png)

###
> 'wc -m lorem-ipsum.txt'
![Problem 2](assets/hw-7/LoreIpsumCharacterCount.png)
###
> 'wc -l lorem-ipsum.txt'
![Problem 3](assets/hw-7/LoreIpsumLineCount.png)
###
> 'sort -h file-sizes.txt'
![Problem 4](assets/hw-7/SortedFileSizes.png)
###
>'sort -h -r file-sizes.txt'
![Problem 5](assets/hw-7/ReverseSortedFileSizes.png)
###
>'cut -d, -f3 log.csv
![Problem 6](assets/hw-7/CutIpLog.png)
###
>'cut -d, -f2,3 log.csv'
![Problem 7](assets/hw-7/Cut_DateTimeandIP.png)
###
>'cut -d -f1,4 log.csv'
![Problem 8](assets/hw-7/CutUUIDLogFile.png)
###
>'head -n 3 gibberish.txt
![Problem 9](assets/hw-7/Head3lines.png)
###
>'tail -n 2 gibberish.txt'
![problem 10](assets/hw-7/Tail2LinesGibberish.png)
###
>'tail -n 20 log.csv'
![Problem 11](assets/hw-7/20LinesLogFile.png)
###
>'cat gibberish.txt | grep and'
![Problem 12](assets/hw-7/GrepAndGibberish.png)
###
>'cat gibberish.txt | grep -w we'
![Problem 13](assets/hw-7/grepWewholeword.png)
###
>'Did not complete'
###
>'wc -l fpgas.txt | cut -d' ' -f1'
![Problem 15](assets/hw-7/fpgaslinecount_cut.png)
###
>'Did not complete'
###
>'grep -cr --include "*.vhd" '--' ../EELE467-Repo/hdl/*'
![Problem 17](assets/hw-7/ListComments.png)
So on this one, none of my comments start a new line. They're all indented which grep doesn't like. Also I only have one vhd file in my hdl folder as the rest are in sim. 
###

>'ls > ls-output.txt && cat ls-output.txt'
![Problem 18](assets/hw-7/redirectLSOutput.png)
However, this does not work with my terminal since I repalced ls with lsx. So I did a different thing instead. 
![Problem 18](assets/hw-7/pipingoutput.png)
###
>'sudo dmesg | grep cpu'
![Problem 19](assets/hw-7/grepdmesgCPU.png)
###
>'find ../EELE467-Repo/hdl/ -iname '*.vhd' | wc -l'
![Problem 20](assets/hw-7/findandwordcount.png)
###
>'grep -cr --include "*.vhd" '.*--.*' ../EELE467-Repo/hdl/*'
![Problem 21](assets/hw-7/countTotalNumberofComments.png)
###
>'cat fpgas.txt | grep -n FPGAs | cut -d':' -f1'
![Problem 22](assets/hw-7/FilteronlyLineNumbersofGPAS.png)
###
>'du -h * | sort -hr | head -n 3'
![Problem 23](assets/hw-7/FilterforLargest3Directories.png)


