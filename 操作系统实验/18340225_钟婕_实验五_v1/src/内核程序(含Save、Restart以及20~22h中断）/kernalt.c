#include "PCB.h"

extern void clear();
extern char scanfCh(); 
extern void printfCh(int c);
extern void UP(int sec);
extern void RT(int sec);
extern void T22();

void InStr(char *cmd);
void print(char *cmd);
int Cmp(char *a, char* b);
void help();
void ANLcmd(char * cmd);
void Runcmd(char* cmd);
void tree();
void init_Pro();
void Menu();

char InCh;
int end=1;
int flag = 1;
char command[1000];

int segment = 0x1200;
int sec = 8;

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
void print(char *str)
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
	print("\n\rhelp-display the command list.\n\r");
	print("cls-clear the window.\n\r");
	print("UP1-run the first program of user.\n\r");
	print("UP2-run the second program of user.\n\r");
	print("UP3-run the third program of user.\n\r");
	print("UP4-run the fourth program of user.\n\r");
	print("test-run the libs program.\n\r");
	print("dir-display the table of UPInfo.\n\r");
	print("ls-dispaly the tree of files.\n\r");
	print("batch-run a series of commands.\n\r");
	print("qb-exit the DIY running.\n\r");
	print("quit-exit the system.\n\r");
}

void Runcmd(char* cmd)
{
	if (Cmp(cmd, "UP1"))
	{
		clear();
		UP(49);
		clear();
	}
	else if (Cmp(cmd, "UP2"))
	{
		clear();
		UP(50);
		clear();
	}
	else if (Cmp(cmd, "UP3"))
	{
		clear();
		UP(51);
		clear();
	}
	else if (Cmp(cmd, "UP4"))
	{
		clear();
		UP(52);
		clear();
	}
	else if (Cmp(cmd, "dir"))
	{
		clear();
		UP(53);
		clear();
	}
	else if (Cmp(cmd, "test"))
	{
		clear();
		RT(56);
		clear();
	}
	else if (Cmp(cmd, "batch"))
	{
		clear();
		print("Please separate cmds by Spaces.\n\r");
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
	else if (Cmp(cmd, "ls"))
	{
		tree();
	}
	else if (Cmp(cmd, "quit"))
	{
		end = 0;
	}
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
			Runcmd(subcmd);
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
		Runcmd(subcmd);
	}
}


void tree()
{
	print("\n\r|-boot.bin\n\r");
	print("|--kernal.com\n\r");
	print("|--------rukou.asm\n\r");
	print("|--------PCB.h\n\r");
	print("|--------kernal.c\n\r");
	print("|--------bacis.asm\n\r");
	print("|------UP1.com\n\r");
	print("|------UP2.com\n\r");
	print("|------UP3.com\n\r");
	print("|------UP4.com\n\r");
	print("|------test.com\n\r");
	print("|--------enter.asm\n\r");
	print("|--------Stuct.h\n\r");
	print("|--------test.c\n\r");
	print("|--------libs.asm\n\r");
	print("|------table.com\n\r");
	print("|------Loading.com\n\r");
	print("|------Close.com\n\r");
}


void init_Pro()  /*创建内核和用户程序的PCB块*/
{
	initial(&pcb[0], 0x0800, 0x100);
	initial(&pcb[1], 0x1200, 0x100);
}



void Menu()
{
	print("          .  .   .                 ,             .__. __.      \n\r");
	print("          |  | _ | _. _ ._ _  _   -+-_  ._ _    .|  |(__       \n\r");
	print("          |/\|(/,|(_.(_)[ | )(/,   |(_)  [ | )\_|  |__|.__)      \n\r");
	print("                                              ._|                \n\r");
	print("*****************************************************************\n\r");
	print("|           Author:Jie Zhong  Student Number:18340225           |\n\r");
	print("|             Input help to view the command list.              |\n\r");
	print("|                     Have a good time!                         |\n\r");
	print("*****************************************************************\n\r");
}

cmain()
{
	UP(54);
	clear();
	init_Pro();
	T22();
	clear();
	Menu();
	while (end)
	{
		print("\n\r>>");
		InStr(command);
		Runcmd(command);
	}
	clear();
	clear();
	UP(55);
	clear();
	print("\n\rQuit! Bye-bye!");
	scanfCh();
}
