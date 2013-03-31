BEGIN{numPackets = 0; packetDelayAverage = 0;lossPackets = 0;}
{
	action = $1;
	time = $2;
	layer = $4;
	type = $5;
	packetID = $6;
	packetID_ = $12;

	if (action == "s" && layer == "AGT"){
		startTime[packetID] = time;
		packetId[numPackets++] = packetID;	
	} else if (action == "r" && (type == "tcp" || type == "cbr")){
		endTime[packetID_] = time;
	}
}

END{
	for(i = 0; i < numPackets; i++) {
		if(endTime[packetId[i]] == 0){ #Verifica se pacote nao chegou ao destino
			numPackets = numPackets - 1;
		} else {			
			packetDelayAverageVector[i] = endTime[packetId[i]]-startTime[packetId[i]];
			printf("%d %.9f %.9f %.9f\n",packetId[i],startTime[packetId[i]],endTime[packetId[i]],packetDelayAverageVector[i]);
		}
	}
	for(i = 0; i < numPackets; i++) {
		packetDelayAverage += packetDelayAverageVector[i];
	}
	packetDelayAverage = packetDelayAverage/numPackets;
	#printf("%.9f",packetDelayAverage);
}


