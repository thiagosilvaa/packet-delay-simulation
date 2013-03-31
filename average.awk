BEGIN{numPackets = 0; sum = 0;}
{
	sum += $4;
	numPackets++;
}

END{
	average = (sum/numPackets);
	printf("%.9f",average);
}
