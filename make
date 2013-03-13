#!/bin/bash
echo "Gerando Simulacao..."
ns packet-delay-sim.tcl 
echo "Simulacao finalizada!"
echo "Processando dados..."
cat packet-delay-sim.tr | grep " tcp " > tcpTypeInfo.txt
awk -f data-processor.awk tcpTypeInfo.txt > packetDelayAverage.txt
echo "Processamento de dados finalizado!"
echo "Gerando graficos..."
gnuplot -persist <<PLOT
plot 'packetDelayAverage.txt'

