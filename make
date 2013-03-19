#!/bin/bash
echo "Simulando..."
> packetDelayAverage.txt
for i in {1..5}
do 
	echo "Numero de estacoes: $i"
	ns packet-delay-sim.tcl -nn $i
	echo "Processando dados..."
	cat packet-delay-sim.tr | grep " tcp " > tcpTypeInfo.txt
	echo "$i $(awk -f data-processor.awk tcpTypeInfo.txt)" >> packetDelayAverage.txt
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
