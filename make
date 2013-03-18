#!/bin/bash
echo "Simulando..."
#> packetDelayAverage.txt
for i in {1..3}
do 
	echo "Numero de estacoes: $i"
	#echo "$i " >> packetDelayAverage.txt
	ns packet-delay-sim.tcl -nn $i
	echo "Processando dados..."
	cat packet-delay-sim.tr | grep " tcp " > tcpTypeInfo.txt
	average = $(awk -f data-processor.awk tcpTypeInfo.txt)
	echo $i $average >> packetDelayAverage.txt
done
#echo "Processamento de dados finalizado!"
echo "Simulacoes finalizadas!"
#echo "Gerando grafico..."
#gnuplot -persist <<PLOT
#plot 'packetDelayAverage.txt' with
