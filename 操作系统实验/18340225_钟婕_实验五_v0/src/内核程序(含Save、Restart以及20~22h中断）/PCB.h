

typedef struct {
	int SS;
	int GS;
	int FS;
	int ES;
	int DS;
	int DI;
	int SI;
	int BP;
	int SP;
	int BX;
	int DX;
	int CX;
	int AX;
	int IP;
	int CS;
	int FLAGS;
}RegImg;

typedef struct 
{
	RegImg RI;
	int Process_Status;
}PCB;

int NEW = 0;
int Ready = 1;
int Run = 2;
int Exit = 3;
PCB pcb[10];
int cur_pnum = 0;/*0�±�Ϊ�ں˳���1~4Ϊ�ĸ��û�����*/
int process_num = 0;

PCB *Current_PCB();
void initial(PCB* p, int segment, int offset);
/*void Save_PCB(int gs, int fs, int es, int ds, int di, int si, int bp,
	int sp, int dx, int cx, int bx, int ax, int ss, int ip, int cs, int flags);*/
void Save_PCB(int gs, int fs, int es, int ds, int di, int si, int bp,
	int sp, int dx, int cx, int bx, int ax, int ss);
void Save_PSP(int ip, int cs, int flags);
void Process_Schedule();
void Fornew();
void Exchange();


PCB* Current_PCB()
{
	return &pcb[cur_pnum];
}

void initial(PCB* p,int segment,int offset)
{
	p->RI.GS = 0xb800;/*�Դ�*/
	p->RI.SS = segment;
	p->RI.ES = segment;
	p->RI.DS = segment;
	p->RI.CS = segment;
	p->RI.FS = segment;
	p->RI.IP = offset;
	p->RI.SP = offset - 4;
	p->RI.AX = 0;
	p->RI.BX = 0;
	p->RI.CX = 0;
	p->RI.DX = 0;
	p->RI.DI = 0;
	p->RI.SI = 0;
	p->RI.BP = 0;
	p->RI.FLAGS = 512;
	if (segment == 0x0800)
		p->Process_Status = Run;
	else
	    p->Process_Status = NEW;
}

/*ip\cs\flags���û��������е����жϵ�ʱ���Ѿ���ջ��˲�����ջʱ��ss��ʼ*/
/*void Save_PCB(int gs, int fs, int es, int ds, int di, int si, int bp,
	int sp, int dx, int cx, int bx, int ax, int ss, int ip, int cs, int flags)
{
	pcb[cur_pnum].RI.AX = ax;
	pcb[cur_pnum].RI.BX = bx;
	pcb[cur_pnum].RI.CX = cx;
	pcb[cur_pnum].RI.DX = dx;

	pcb[cur_pnum].RI.DS = ds;
	pcb[cur_pnum].RI.ES = es;
	pcb[cur_pnum].RI.FS = fs;
	pcb[cur_pnum].RI.GS = gs;
	pcb[cur_pnum].RI.SS = ss;

	pcb[cur_pnum].RI.DI = di;
	pcb[cur_pnum].RI.SI = si;
	pcb[cur_pnum].RI.SP = sp;
	pcb[cur_pnum].RI.BP = bp;

	pcb[cur_pnum].RI.IP = ip;
	pcb[cur_pnum].RI.CS = cs;
	pcb[cur_pnum].RI.FLAGS = flags;
	
}*/

void Save_PCB(int gs, int fs, int es, int ds, int di, int si, int bp,
	int sp, int dx, int cx, int bx, int ax, int ss)
{
	pcb[cur_pnum].RI.AX = ax;
	pcb[cur_pnum].RI.BX = bx;
	pcb[cur_pnum].RI.CX = cx;
	pcb[cur_pnum].RI.DX = dx;

	pcb[cur_pnum].RI.DS = ds;
	pcb[cur_pnum].RI.ES = es;
	pcb[cur_pnum].RI.FS = fs;
	pcb[cur_pnum].RI.GS = gs;
	pcb[cur_pnum].RI.SS = ss;

	pcb[cur_pnum].RI.DI = di;
	pcb[cur_pnum].RI.SI = si;
	pcb[cur_pnum].RI.SP = sp;
	pcb[cur_pnum].RI.BP = bp;
}

void Save_PSP(int ip, int cs, int flags)
{
	pcb[cur_pnum].RI.IP = ip;
	pcb[cur_pnum].RI.CS = cs;
	pcb[cur_pnum].RI.FLAGS = flags;
}

void Process_Schedule()
{
	/*pcb[cur_pnum].Process_Status = Ready;*/
	/*cur_pnum++;*/
	/*if (cur_pnum > process_num)
		cur_pnum = 1;/*�ĸ��û�������ִ��ֱ����ִ����ɣ���˴ӵ��ĸ�������ȵ�һ��������Ҫ��1*/
	if (pcb[cur_pnum].Process_Status != NEW)
		pcb[cur_pnum].Process_Status = Run;/*�ر�ע�⣡�������ӣ�����һ�����еĳ�����Ѿ����еĳ�����ִ���ǲ�ͬ�ģ�*/

}

void Fornew()
{
	if (pcb[cur_pnum].Process_Status == NEW)
		pcb[cur_pnum].Process_Status = Run;
}

void Exchange()
{
	if (cur_pnum == 0)
		cur_pnum = 1;
}
