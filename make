#!/bin/bash
echo "Simulando..."
> packetDelayAverage.txt
for i in {1..1}
do 
	echo "Numero de estacoes: $i"
	ns packet-delay-sim.tcl -nn $i -tptraffic cbr
	echo "Processando dados..."
	cat packet-delay-sim.tr | grep " cbr " > cbrTypeInfo.txt
	awk 'NR >= 1000 && NR < 1100' cbrTypeInfo.txt > cbrTypeInfoSamples.txt
	echo "$i $(awk -f data-processor.awk cbrTypeInfoSamples.txt)" >> packetDelayAverage.txt
	rm -f *.tr *.nam cbrTypeInfo.txt cbrTypeInfoSamples.txt
done
#echo "Processamento de dados finalizado!"
echo "Simulacoes finalizadas!"
echo "Gerando grafico..."
gnuplot -persist <<PLOT
reset
set grid
set title "Packet Delay Simulation"
set xlabel "number of nodes"
set ylabel "Average delay(sec)"
plot 'packetDelayAverage.txt' with lines
