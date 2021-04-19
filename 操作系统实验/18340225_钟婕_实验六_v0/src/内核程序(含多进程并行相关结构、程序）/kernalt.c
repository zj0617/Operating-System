#include "PCB.h"

extern void clear();
extern char scanfCh(); 
extern void printfCh(int c);
extern void UP(int sec);
extern void RT(int sec);
extern void T22();
extern void ChangeTimer();
extern void LoadPro(int segment, int sec);

void InStr(char *cmd);
void print(char *cmd);
void Load(char *cmd);
int Cmp(char *a, char* b);
void help();
void DirEntry();
void ANLcmd(char * cmd);
void Runcmd(char* cmd);
void tree();
void init_Pro();
void Menu();

char InCh;
int end=1;
int flag = 1;
char command[1000];

int segment = 0x2000;
int sec = 0;

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
	print("p1234-run the four UP in order. You can change the order od numbers.\n\r");
	print("test-run the libs program.\n\r");
	print("dir-display the table of UPInfo.\n\r");
	print("ls-dispaly the tree of files.\n\r");
	print("batch-run a series of commands.\n\r");
	print("qb-exit the DIY running.\n\r");
	print("quit-exit the system.\n\r");
}

void Delay()
{
	int i = 0;
	int j = 0;
	for (i = 0; i < 10000; i++)
		for (j = 0; j < 10000; j++)
		{
			j++;
			j--;
		}
}

/*分时并行执行时将需要并行执行的用户程序加载至相应内存*/
void Load(char *cmd)
{
	int i = 1;
	int num = 0;
	int count = 0;
	while (cmd[i] != '\0' && (cmd[i] >= 0+'0'&&cmd[i] <=9+'0'))
	{
		num = cmd[i] - '0';/*获得扇区号*/
		sec = num;
		LoadPro(segment,sec);
		segment += 0x1000;
		count++;
		i++;
	}
	process_num = count;/*当前准备并行执行的进程数*/
}
void DirEntry()
{
	print("\n\r Total File Number: 7\n\r");
	print("      FileName      ||    Addr      || FileSize\n\r");
	print("  UP1:Square        || 2400H~2600H  || 407Bytes\n\r");
	print("  UP2:Single stone  || 2600H~2800H  || 438Bytes\n\r");
	print("  UP3:Double stone  || 2800H~2A00H  || 508Bytes\n\r");
	print("  UP4:Sand Clock    || 2A00H~2C00H  || 326Bytes\n\r");
	print("  Test              || 3200H~3A00H  || 1686Bytes\n\r");
	print("  Loading           || 2E00H~3000H  || 512Bytes\n\r");
	print("  Close             || 3000H~3200H  || 392Bytes\n\r");
}
void Runcmd(char* cmd)
{
	if (cmd[0] == 'p')
	{
		clear();
		Load(cmd);
		Delay();
		clear();
	}
	else if (Cmp(cmd, "dir"))
	{
		clear();
		DirEntry();
	}
	else if (Cmp(cmd, "test"))
	{
		clear();
		Load("p8");
		Delay();
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
	else
	{
		print("\n\rPlease input the correct instructions.\n\r");
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
			init_Pro(1);
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
		init_Pro(1);
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
	print("|------Loading.com\n\r");
	print("|------Close.com\n\r");
}


void init_Pro(int f)  /*创建内核和用户程序的PCB块*/
{
	if (f == 0)
		initial(&pcb[0], 0x1000, 0x100);
	initial(&pcb[1], 0x2000, 0x100);
	initial(&pcb[2], 0x3000, 0x100);
	initial(&pcb[3], 0x4000, 0x100);
	initial(&pcb[4], 0x5000, 0x100);
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
	clear();
	ChangeTimer();
	init_Pro(0);
	Runcmd("p6");
	clear();
	T22();
	clear();
	Menu();
	while (end)
	{
		init_Pro(1);
		print("\n\r>>");
		InStr(command);
		Runcmd(command);
	}
	clear();
	Runcmd("p7");
	clear();
	print("\n\rQuit! Bye-bye!");
	scanfCh();
}
