#==================================================================
#  Redes de Computadores Sem Fio - Trabalho
#  Autores: Raif Carneiro Gomes
#	    Thiago Silva Agostinho	
#  Eng. de Telecomunicações - S8
#
#      -- Estudo de Delay --
#
#  Criar nos wireless onde cada um envia dados ao servidor.
#  Medir o delay para vários tipos de trafegos.
#  Variar a taxa para cada fluxo e tambem o numero de fluxos e 
#  de estações e calcular o delay.
#  Comparar resultados com os obtidos no artigo4.pdf.
#==================================================================


global opt
set opt(chan)       Channel/WirelessChannel
set opt(prop)       Propagation/TwoRayGround
set opt(netif)      Phy/WirelessPhy
set opt(mac)        Mac/802_11
set opt(ifq)        Queue/DropTail/PriQueue
set opt(ll)         LL
set opt(ant)        Antenna/OmniAntenna
set opt(x)             670   
set opt(y)              670   
set opt(ifqlen)         50   
set opt(tr)          packet-delay-sim.tr
set opt(namtr)       packet-delay-sim.nam
set opt(nn)             1                       
set opt(adhocRouting)   DSDV                      
set opt(cp)             ""                        
set opt(sc)             "../mobility/scene/scen-3-test"   
set opt(stop)           60                           
set opt(tptraffic)	ftp
set num_wired_nodes      1
set num_bs_nodes         1

#Captura parametros de entrada da simulacao
proc getopt {argc argv} {
        global opt
        lappend optlist 
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
                set name [string range $arg 1 end]
                set opt($name) [lindex $argv [expr $i+1]] 
        }         
}

getopt $argc $argv


set ns_   [new Simulator]
# set up for hierarchical routing
$ns_ node-config -addressType hierarchical
AddrParams set domain_num_ 2          
lappend cluster_num 1 1                
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 2              
AddrParams set nodes_num_ $eilastlevel 

set tracefd  [open $opt(tr) w]
$ns_ trace-all $tracefd
set namtracefd [open $opt(namtr) w]
$ns_ namtrace-all $namtracefd

set topo   [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
# god needs to know the number of all wireless interfaces
create-god [expr $opt(nn) + $num_bs_nodes]

#create wired nodes
set temp {0.0.0}        
set W(0) [$ns_ node [lindex $temp 0]]
$W(0) label "SERVER"
$W(0) shape "square"
$W(0) color "red"

$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propInstance [new $opt(prop)] \
                 -phyType $opt(netif) \
                 -channel [new $opt(chan)] \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace ON

set temp {1.0.0 1.0.1 1.0.2 1.0.3}
set BS(0) [$ns_ node [lindex $temp 0]]
$BS(0) random-motion 0 

$BS(0) label "AP"
$BS(0) shape "hexagon"
$BS(0) color "blue"

$BS(0) set X_ 1.0
$BS(0) set Y_ 2.0
$BS(0) set Z_ 0.0
  
  
#configure for mobilenodes
$ns_ node-config -wiredRouting OFF
  
set index {1}
for {set j 0} {$j < $opt(nn)} {incr j} {
	set node_($j) [ $ns_ node 1.0.$index ]
	incr index	
    	$node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]]
  }

#create links between wired and BS nodes
$ns_ duplex-link $W(0) $BS(0) 5Mb 2ms DropTail

if {$opt(tptraffic) == "ftp"} {
	for {set j 0} {$j < $opt(nn)} {incr j} {
		# setup TCP connections
		set tcp($j) [new Agent/TCP]
		$tcp($j) set class_ 2
		set sink($j) [new Agent/TCPSink]
		$ns_ attach-agent $node_($j) $tcp($j)
		$ns_ attach-agent $W(0) $sink($j)
		$ns_ connect $tcp($j) $sink($j)
		set ftp($j) [new Application/FTP]
		$ftp($j) attach-agent $tcp($j)
		$ns_ at 1.0 "$ftp($j) start"
	}
}

if {$opt(tptraffic) == "cbr"} {
	for {set j 0} {$j < $opt(nn)} {incr j} {
		# setup TCP connections
		set tcp($j) [new Agent/TCP]
		$tcp($j) set class_ 2
		set sink($j) [new Agent/TCPSink]
		$ns_ attach-agent $node_($j) $tcp($j)
		$ns_ attach-agent $W(0) $sink($j)
		$ns_ connect $tcp($j) $sink($j)
		set cbr($j) [new Application/Traffic/CBR]
		$cbr($j) attach-agent $tcp($j)
		$ns_ at 1.0 "$cbr($j) start"
	}
}

  
for {set i 0} {$i < $opt(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 20
}

for {set i } {$i < $opt(nn) } {incr i} {
	$ns_ at $opt(stop) "$node_($i) reset";
}

#Procedures
proc finish {} {
    	global ns_ namtracefd tracefd
    	$ns_ flush-trace
   	close $namtracefd
    	close $tracefd
    	exec nam packet-delay-sim.nam &
    	exit 0
}

$ns_ at $opt(stop).0000010 "$BS(0) reset";
$ns_ at $opt(stop).1 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0000010 "finish";

puts "Starting Simulation..."
$ns_ run
