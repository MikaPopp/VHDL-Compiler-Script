#!/bin/bash

if [ "$1" == "" ]; then
	echo "Please enter at least one file"
else
	declare -i c=1
	for var in "$@"
	do
		echo "File $c '$var':"
		if ghdl -s $var 2> /dev/null; then
			echo "Syntax-check OK"
			if ghdl -a $var 2> /dev/null; then
				echo "Analysis OK"
				entity_name=$(cat $var 2> /dev/null | grep -Po '(?<=(entity )).*(?= is)' 
				2> /dev/null) 
				if ghdl -e $entity_name 2> /dev/null; then
					echo "Build OK"
					if ghdl -r $entity_name --vcd=testbench$c.vcd > /dev/null 2>&1; then
						echo "VCD-Dump OK"
						gtkwave testbench$c.vcd &> /dev/null &
						echo "Starting GTKWave"
					else 
						echo "VCD-Dump Failed"
					fi
				else 
					echo "Build Failed"
				fi
			else 
				echo "Analysis Failed"
			fi
		else 
			echo "Syntax-check Failed"
		fi
		echo ""
		((c=c+1))
	done
fi
