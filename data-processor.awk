BEGIN{numPackets = 0;}
{
	if ($1 == "s" && $4 = "MAC"){
		startTime[$6] = $2;
		packetId[numPackets++] = $6;	
	} else if ($1 == "r" && $5 == "tcp"){
		endTime[$12] = $2;
	}
}

END{
	for(i = 0; i < numPackets; i++) {
		printf("%.9f,%.9f\n",startTime[packetId[i]],endTime[packetId[i]]);
	}		
	
}


