#include "Stuct.h"

extern void fst();
extern void cls();
extern void getch(char* c);
extern void putch(char c);
extern void puts(char *s);
extern void gets(char *s);
extern void scanf(char*s, char *c);

char Ch;
char s[1000];

int segment = 0x1300;
int sec = 8;

void getstr(char * s)
{
	int index = 0;
	getch(&Ch);
	while (Ch != 13)
	{
		if (Ch == 8)
		{
			if (index != 0)
			{
				putch(Ch);
				putch(32);
				index--;
				putch(Ch);
				getch(&Ch);
				continue;
			}
			else
			{
				getch(&Ch);
				continue;
			}
		}
		putch(Ch);
		s[index] = Ch;
		index++;
		getch(&Ch);
	}
	s[index] = '\0';
}
void putstr(char *str)
{
	int i = 0;
	while (str[i] != 0)
	{
		putch(str[i]);
		i++;
	}
}

void printf(char *str)
{
	int i = 0;
	while (str[i] != 0)
	{
		putch(str[i]);
		i++;
	}
}

void scanfstr(char*s1, char*s2)
{
	if (s1[0] == '%'&&s1[1] == 'd')
		getch(s2);
	if (s1[0] == '%'&&s1[1] == 's')
		gets(s2);
}

void init_Pro()  /*创建内核和用户程序的PCB块*/
{
	initial(&pcb[0], 0x1300, 0x100);
}


main()
{
	fst();
	init_Pro();
	printf("Input a char and output a char\r\n");
	getch(&Ch);
	putch(Ch);
	putch(' ');
	putch(Ch);
	putch(13);
	putch(10);
	printf("Input a str and output a str\r\n");
	gets(s);
	putch('\r');
	putch('\n');
	puts(s);
	putch('\r');
	putch('\n');
	printf("Input a char and output a char\r\n");
	scanf("%d", &Ch);
	putch(Ch);
	putch(' ');
	putch(Ch);
	puts("\r\n");
	printf("Input a str and output a str\r\n");
	scanf("%s", s);
	puts("\r\n");
	printf(s);
	puts("\r\n");
	printf("Input quit to exit\r\n");
	gets(s);
}