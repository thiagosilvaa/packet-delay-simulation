BEGIN{lastPacketId = 0;}
{
	action = $1;
	time = $2;
	origin = $3;
	layer = $4;
	flags = $5;
	packetId = $6;
	type = $7;
	size = $8;
	flow = $9;
	flags_ = $10;	
	seqno = $11;
	if (type == "tcp"){
		if (action == "s"){
			startTime[packetId] = time;	
		} else if (action == "r"){
			endTime[packetId] = time;
		}
		lastPacketId = packetId;
	}
}

END{
	for(packetId = 1; packetId<lastPacketId; packetId++){
		start = startTime[packetId];
		end = endTime[packetId];
		delay = end-start;
		printf("%f\n",delay);		
	}
}


