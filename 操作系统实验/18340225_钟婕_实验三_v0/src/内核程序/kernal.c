
extern void clear();
extern char scanfCh(); 
extern void printfCh(int c);
extern void UP(int sec);

char InCh;
int end=1;
int flag = 1;
char command[1000];
void Run(char *cmd);

void InStr(char * cmd)
{
	int index = 0;
	scanfCh();
	while (InCh != 13)
	{
		if (InCh == 8)
		{
			if (index != 0)
			{
				printfCh(InCh);
				printfCh(32);
				index--;
				printfCh(InCh);
				scanfCh();
				continue;
			}
			else
			{
				scanfCh();
				continue;
			}
		}
		printfCh(InCh);
		cmd[index] = InCh;
		index++;
		scanfCh();
	}
	cmd[index] = '\0';
}
void printf(char *str)
{
	int i = 0;
	while (str[i] != 0)
	{
		printfCh(str[i]);
		i++;
	}
}
int Cmp(char *a, char *b)
{
	int i = 0;
	int j = 0;
	while (a[i] != 0 && b[j] != 0)
	{
		if (a[i] != b[j])
		{
			return 0;
		}
		i++;
		j++;
	}
	if (a[i] == 0 && b[j] == 0)
		return 1;
}
void help()
{
	printf("\n\rhelp-display the command list.\n\r");
	printf("cls-clear the window.\n\r");
	printf("UP1-run the first program of user.\n\r");
	printf("UP2-run the second program of user.\n\r");
	printf("UP3-run the third program of user.\n\r");
	printf("UP4-run the fourth program of user.\n\r");
	printf("table-display the table of UPInfo.\n\r");
	printf("DIY-run a series of commands.\n\r");
	printf("qb-exit the DIY running.\n\r");
	printf("quit-exit the system.\n\r");
}
void ANLcmd(char * cmd)
{
	int index = 0;
	char subcmd[10];
	int j = 0;
	while (cmd[index] != '\0'&&end&&flag)
	{
		if (cmd[index] == 32)
		{
			subcmd[j] = '\0';
			Run(subcmd);
			j = 0;
		}
		else
		{
			subcmd[j] = cmd[index];
			j++;
		}
		index++;
	}
	if (cmd[index] == '\0')
	{
		subcmd[j] = '\0';
		Run(subcmd);
	}
}

void Run(char* cmd)
{
	if (Cmp(cmd, "UP1"))
	{
		clear();
		UP(56);
		clear();
	}
	else if (Cmp(cmd, "UP2"))
	{
		clear();
		UP(57);
		clear();
	}
	else if (Cmp(cmd, "UP3"))
	{
		clear();
		UP(58);
		clear();
	}
	else if (Cmp(cmd, "UP4"))
	{
		clear();
		UP(59);
		clear();
	}
	else if (Cmp(cmd, "table"))
	{
		clear();
		UP(60);
		clear();
	}
	else if (Cmp(cmd, "DIY"))
	{
		clear();
		printf("Please separate cmds by Spaces.\n\r");
		InStr(command);
		ANLcmd(command);
	}
	else if (Cmp(cmd, "qb"))
	{
		flag = 0;
	}
	else if (Cmp(cmd, "help"))
	{
		help();
	}
	else if (Cmp(cmd, "cls"))
	{
		clear();
	}
	else if (Cmp(cmd, "quit"))
	{
		end = 0;
	}
}





void Menu()
{
	printf("          .  .   .                 ,               .__. __.      \n\r");
	printf("          |  | _ | _. _ ._ _  _   -+-_   ._ _   .  |  |(__       \n\r");
	printf("          |/\|(/,|(_.(_)[ | )(/,   |(_)  [ | )\_|  |__|.__)      \n\r");
	printf("                                              ._|                \n\r");
	printf("*****************************************************************\n\r");
	printf("|           Author:Jie Zhong  Student Number:18340225           |\n\r");
	printf("|             Input help to view the command list.              |\n\r");
	printf("|                     Have a good time!                         |\n\r");
	printf("*****************************************************************\n\r");
}

cmain()
{
	UP(61);
	clear();
	Menu();
	while (end)
	{
		printf("\n\r>>");
		InStr(command);
		Run(command);
	}
	clear();
	printf("\n\rQuit! Bye-bye!");
	scanfCh();
}
