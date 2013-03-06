#!/bin/bash
echo "Gerando Simulacao..."
ns packet-delay-sim.tcl
echo "Simulacao finalizada!"
echo "Processando dados..."
awk -f data-processor.awk packet-delay-sim.tr > packetDelayAverage.txt
echo "Processamento de dados finalizado!"
echo "Gerando graficos..."
gnuplot -persist <<PLOT
plot 'packetDelayAverage.txt'

