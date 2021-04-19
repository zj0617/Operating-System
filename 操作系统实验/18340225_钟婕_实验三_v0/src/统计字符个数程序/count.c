


char num='0';

count(char *str)
{
	int index = 0;
	while (str[index] != 0)
	{
		if (str[index] == 'o')
			num++;
		index++;
	}
}