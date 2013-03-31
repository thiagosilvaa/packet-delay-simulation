#!/bin/bash
echo "Simulando..."
> ftpPacketDelayAverage.txt
> cbrPacketDelayAverage448Kb.txt
> cbrPacketDelayAverage512Kb.txt
> cbrPacketDelayAverage1Mb.txt
> cbrPacketDelayAverage5Mb.txt

echo "========================================="
echo "FTP traffic"
echo "========================================="

for i in {1..5}
do 
	echo "Numero de estacoes: $i"
	ns packet-delay-sim.tcl -nn $i 
	echo "Processando dados..."
	awk -f data-processor.awk packet-delay-sim.tr > info.txt
	echo "$i $(awk -f average.awk info.txt)" >> ftpPacketDelayAverage.txt
	rm -f *.tr *.nam info.txt
done

echo "========================================="
echo "CBR traffic - rate = 448Kb(ns2 default)\n"
echo "========================================="

for i in {1..5}
do 
	echo "Numero de estacoes: $i"
	ns packet-delay-sim.tcl -nn $i -tptraffic cbr #default cbr rate 448Kb
	echo "Processando dados..."
	awk -f data-processor.awk packet-delay-sim.tr > info.txt
	echo "$i $(awk -f average.awk info.txt)" >> cbrPacketDelayAverage448Kb.txt
	rm -f *.tr *.nam info.txt
done

echo "========================================="
echo "CBR traffic - rate = 512Kb\n"
echo "========================================="

for i in {1..5}
do 
	echo "Numero de estacoes: $i"
	ns packet-delay-sim.tcl -nn $i -tptraffic cbr -rate 512Kb
	echo "Processando dados..."
	awk -f data-processor.awk packet-delay-sim.tr > info.txt
	echo "$i $(awk -f average.awk info.txt)" >> cbrPacketDelayAverage512Kb.txt
	rm -f *.tr *.nam info.txt
done

echo "========================================="
echo "CBR traffic - rate = 1Mb\n"
echo "========================================="

for i in {1..5}
do 
	echo "Numero de estacoes: $i"
	ns packet-delay-sim.tcl -nn $i -tptraffic cbr -rate 1Mb
	echo "Processando dados..."
	awk -f data-processor.awk packet-delay-sim.tr > info.txt
	echo "$i $(awk -f average.awk info.txt)" >> cbrPacketDelayAverage1Mb.txt
	rm -f *.tr *.nam info.txt
done

echo "========================================="
echo "CBR traffic - rate = 5Mb\n"
echo "========================================="

for i in {1..5}
do 
	echo "Numero de estacoes: $i"
	ns packet-delay-sim.tcl -nn $i -tptraffic cbr -rate 5Mb
	echo "Processando dados..."
	awk -f data-processor.awk packet-delay-sim.tr > info.txt
	echo "$i $(awk -f average.awk info.txt)" >> cbrPacketDelayAverage5Mb.txt
	rm -f *.tr *.nam info.txt
done

echo "Simulacoes finalizadas!"
echo "Processamento de dados finalizado!"
echo "Gerando grafico..."
gnuplot -persist <<PLOT
reset
set grid
set xtics 1
set xrange[1:]
set title "Packet Delay Simulation - FTP traffic"
set xlabel "number of nodes"
set ylabel "Average delay(sec)"
plot 'ftpPacketDelayAverage.txt' with lines
set terminal png
set output 'ftpPacketdelay.png'
replot
set title "Packet Delay Simulation - CBR traffic"
set xlabel "number of nodes"
set ylabel "Average delay(sec)"
plot 'cbrPacketDelayAverage448Kb.txt' with lines 1 t"rate=448Kb"
rep 'cbrPacketDelayAverage512Kb.txt' with lines 2 t"rate=512Kb"
rep 'cbrPacketDelayAverage1Mb.txt' with lines 3 t"rate=1Mb"
rep 'cbrPacketDelayAverage5Mb.txt' with lines 4 t"rate=5Mb"
set terminal png
set output 'cbrPacketdelay.png'
replot
