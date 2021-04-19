#include <iostream>
#include <algorithm>
#include <math.h>
#include <time.h>
#include <string>
#include <vector>
#include <queue>
#include <map>
#include "define.h"
#define _SCL_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#pragma warning(disable:4996)
using namespace std;
//�ǵ�Ҫ�޸ĵ�ʱ��Ҫ�����ô��ݣ��������������õ���head��root��tab��datapart���Ǹĺõģ�Ȼ���ٸ��ĵ�����������д������(ת����int��)��
bool Header_Format(section * &ramFDD144)//��������������Ƿ����FAT12��ʽ ֻҪ��β���ɣ�
{
	fat12header header;
	if (ramFDD144 == NULL)
		return false;
	return (ramFDD144[0].ram512[510] == 0x55 && ramFDD144[0].ram512[511] == 0xAA);
}
//��ȡ��Ŀ¼��һ��������Ŀ¼��
RootEntry *& make_RootSec(section &s)
{
	RootEntry * r = new RootEntry[16];
	int j = 0;
	int k = 0;
	for (int i = 0,k=0; i < 16&&k<512;k++)
	{
		if (j >= 32)
		{
			j %= 32;
			i++;
		}
		if (j < 11)
		{
			r[i].DIR_Name[j] = s.ram512[k];
		}
		else if (j == 11)
		{
			r[i].DIR_Attr =s.ram512[k];
		}
		else if (j < 22);
		else if (j ==22)
		{
			r[i].DIR_WrtTime=unsigned short(s.ram512[k])+unsigned short(s.ram512[k+1])*256;//С�˷�ʽ��
			j++; 
			k++;
		}
		else if (j == 24)
		{
			r[i].DIR_WrtDate= unsigned short(s.ram512[k]) + unsigned short(s.ram512[k + 1])*256;
			j++;
			k++;
		}
		else if (j == 26)
		{
			r[i].DIR_FstClus= unsigned short(s.ram512[k]) + unsigned short(s.ram512[k + 1])*256;
			j++;
			k++;
		}
		else
		{
			r[i].DIR_FileSize = unsigned int(s.ram512[k]) + unsigned int(s.ram512[k + 1]) * 256 + unsigned int(s.ram512[k + 2])*pow(2, 16) + unsigned int(s.ram512[k + 3])*pow(2, 24);
			j = 31;
			k += 3;
		}
		j++;
	}
	return r;
}
//ת��ʱ��
string Transfer_Time(unsigned short t)
{
	string time = "";
	int s = t % 60;
	t /= 60;
	int m = t % 60;
	int h = t / 60;
	if (h < 10)
		time += "0" + to_string(h) + ":";
	else
	time += to_string(h) + ":";
	if (m < 10)
		time += "0" + to_string(m) + ":";
	else
		time += to_string(m) + ":";
	if (s < 10)
		time += "0" + to_string(s);
	else
		time += to_string(s);
	return time;
}
//ת������,��Ϊ��λ,Ϊ�˼���ÿ����30�����
string Transfer_Date(unsigned short date)
{
	string rdate = "";
	int d = date % 30;
	date /= 30;
	int m=date%12+1;
	int y=date/12+1963;
	rdate += to_string(y) + '.';
	if (m < 10)
		rdate += "0" + to_string(m) + '.';
	else
		rdate += to_string(m) + '.';
	if (d < 10)
		rdate += "0" + to_string(d);
	else
		rdate += to_string(d);
	return rdate;
}
//�г�fdd144���������и�Ŀ¼�ļ�Ŀ¼�����ݡ�
void List_RootEntry(RootEntry &e)
{
	string name = "";
	string time = "";
	string date = "";
	for (int i = 0; i < 11; i++)
	{
		name += e.DIR_Name[i];
	}
	time = Transfer_Time(e.DIR_WrtTime);
	date = Transfer_Date(e.DIR_WrtDate);
	cout << name << "\t";
	//cout << e.DIR_Attr << '\t\t';
	if (e.DIR_Attr == 0x10)
		cout << "<DIR>" << "\t\t";
	else
		cout << "<TXT>" << "\t\t";
	cout << time << "\t\t";
	cout << date << "\t\t";
	//cout << e.DIR_FstClus << '\t\t';
	cout << e.DIR_FileSize <<"Bytes"<< "\t\t";
}
//�����������л�ø�Ŀ¼��,��224��Ŀ¼�����ʽ�洢
RootEntry* Root(section* &ramFDD144)
{
	RootEntry * root;
	root = new RootEntry[224];
	for (int i = 19; i < 33; i++)
	{
		RootEntry *temp = make_RootSec(ramFDD144[i]);
		for (int j = 0; j < 16; j++)
		{
			root[(i - 19) * 16 + j] = temp[j];
		}
	}
	return root;
}
//�г���Ŀ¼������Ŀ¼����
void List_Root(RootEntry *&root)
{
	for (int i = 0; i < 224; i++)
	{
		if (root[i].DIR_Name[0] == '\0')//��Ŀ¼�����ɾ���ļ�����ʾ
			break;
		else if(root[i].DIR_Name[0] != 229)
		{
			List_RootEntry(root[i]);
			cout << endl;
		}
	}
}
//���ݴغ��ҵ���Ӧ���е�����,�д���֤��
unsigned short FindFATClus(unsigned short Clusnum, FATTable &tab)
{
	unsigned short  fatNext = 0xfff;
	int  ItemBase;
	ItemBase = Clusnum / 2 * 3;
	if (Clusnum % 2 == 1)
	{
		ItemBase++;
		fatNext = unsigned short(tab.word[ItemBase]) + unsigned short(tab.word[ItemBase + 1]) * 256;
		fatNext = fatNext >> 4;//34 12 = 12 34 _->123
	}
	else
	{
		fatNext = unsigned short(tab.word[ItemBase]) + unsigned short(tab.word[ItemBase + 1]) * 256;
		fatNext = fatNext & 0xfff;//34 12 = 12 34 ->234
	}
	return  fatNext;
}


//ɾ����Ŀ¼��һ��ָ���ļ�,root����֮����Ҫд��ram144�У����Ƶ�%32���ɣ��ǵ�Ҫд��ram!��ͬʱ�ǵ�Ҫ�޸ĵ�ʱ��Ҫ�����ô��ݣ�
int del_RootEntry(RootEntry * &root, string filename,FATTable& tab)
{
	//������Ҫ���ж��ļ��Ƿ�򿪣�
	bool flag = false;
	for (int i = 0; i < 224; i++)
	{
		if (root[i].DIR_Name[0] == '\0')//��Ŀ¼������
			break;
		string name = "";
		for (int j = 0; j < 11; j++)
		{
			name += root[i].DIR_Name[j];
		}
		if (name == filename)//�Ƚ�ƥ���ļ���
		{
			root[i].DIR_Name[0] = 229;//��Ŀ¼�����ַ��ĳ�E5
			//��Ҫ��ɾ��Ŀ¼������ݴشغŷ���������ݿ������
			vector<unsigned short>clus_list;
			unsigned short fst = root[i].DIR_FstClus;
			while (fst != 0xFFF && fst != 0x000)
			{
				clus_list.push_back(fst + 31);
				fst = FindFATClus(fst, tab);
			}
			for (int x = 0; x < clus_list.size(); x++)
			{
				DP_USE.number.push(clus_list[x]);
			}
			flag = true;
			break;
		}
	}
	if (flag)//�ɹ�ɾ��
		return 1;
	else
		return 0;//δ�ҵ��ļ���ɾ��ʧ��
}

//ʵ�ְ�·���������ļ���·�������㷨��ע�⣡������·���������ص�ָ�벻��ָ��ԭ���������ģ��������ֻ����ʾĿ¼���������������Ҫ����ֵ��Ҫ�ҵ���Ӧ�����ݿ飬����Ҫ�޸ĵ�ԭ���������У�
RootEntry Path_sub(string &subpath, RootEntry *&subcur,FATTable &tab,DataPart &dp,int& in)
{
	if (subcur == NULL)
		return *subcur;
	if (subpath=="/")
		return *subcur;
	string subname = "";
	int index = 0;
	string spath = "";
	RootEntry *scur;
	int i = 0;
	for (i = 1; i < subpath.size(); i++)//��A:/��ͷ��
	{
		if (subpath[i] == '/')
		{
			index = i;
			break;
		}
		subname += subpath[i];
	}
	spath = subpath.substr(index, subpath.size() - index);
	vector<unsigned short>clus_list;
	vector<section>data;
     //��Ŀ¼�е�Ŀ¼���״غţ�
	unsigned short tmp = subcur->DIR_FstClus;
	while (tmp != 0xFFF&&tmp!=0x000)
	{
		clus_list.push_back(tmp+31);
		tmp = FindFATClus(tmp,tab);
	}
	for (int i = 0; i < clus_list.size(); i++)
	{
		data.push_back(dp.part[clus_list[i]-33]);
	}
	vector<RootEntry>sub;//��ǰĿ¼�����ݼ�����Ŀ¼��
	for (int i = 0; i < data.size(); i++)
	{
		RootEntry *r = make_RootSec(data[i]);//һ�����ݿ鼴һ��������Ŀ¼�
		for (int j = 0; j < 16; j++)
			sub.push_back(r[j]);
	}
	i = 0;
	bool flag = false;
	while (sub[i].DIR_Name[0] != '\0')
	{
		if (sub[i].DIR_Name[0] != 229)
		{
			int k = 0;
			for (k = 0; k < 11; k++)
			{
				if (sub[i].DIR_Name[k] != subname[k])
					break;
			}
			if (k == 11)
			{
				flag = true;
				break;
			}

		}
		i++;
	}
	RootEntry t;
	//t.DIR_Name[0] = ' ';
	if (!flag)
	{
		//cout << "Path is wrong!"<<endl;
		return t;
	}
	scur = &sub[i];
	in = clus_list[i / 16] - 33;//ƥ�����Ŀ¼���Ӧ���������������ţ�
	if (spath == "/")
		return *scur;
	return Path_sub(spath, scur, tab, dp,in);
}
RootEntry Path(string &filepath,RootEntry * &cur,FATTable &tab,DataPart &dp,int &in)//��Ŀ¼�е�·��ƥ�䣡
{
	if (filepath.size() == 0)
		return *cur;
	if (cur == NULL)
		return *cur;
	string name = "";
	int index = 0;
	int i = 0;
	string subpath = "";
	RootEntry *subcur;
	RootEntry final;
	for (i = 1; i < filepath.size(); i++)//��/��ͷ��
	{
		if (filepath[i] == '/')//����������������·��ʱҪ��/��β��
		{
			index = i;
			break;
		}
		name += filepath[i];
	}
	subpath = filepath.substr(index, filepath.size() - index);
	i = 0;
	bool flag = false;
	while (cur[i].DIR_Name[0] != '\0')
	{
		if (cur[i].DIR_Name[0] != 229)
		{
			int k = 0;
			for (k = 0; k < 11; k++)
			{
				if (cur[i].DIR_Name[k] != name[k])
					break;
			}
			if (k==11)
			{
				flag = true;
				break;
			}
	
		}
		i++;
	}
	RootEntry t;
	//t.DIR_Name[0] =' ';
	if (!flag)
		return t;
	subcur = &cur[i];
	if (subpath=="/")
	{
		in = i / 16 + 19;
		return *subcur;
	}
	final = Path_sub(subpath,subcur,tab,dp,in);
	return final;
}
//���ļ�
RootEntry* OpenFile(string path, int rw, RootEntry *root, FATTable &tab, DataPart &dp)
{
	if (path.size() == 0)
		return NULL;
	RootEntry *fp = NULL;
	int in = 0;
	fp = &Path(path, root, tab, dp,in);
	if (fp == NULL||fp->DIR_Attr==0x01)
	{
		cout << "Path is wrong!" << endl;
		return NULL;
	}
	int index = 0;
	bool ext = false;
	for (int i = 0; i < 100; i++)
	{
		if (FILE_active_list[i].path == "")
		{
			index = i;
			break;
		}
		else if (FILE_active_list[i].path == path)
		{
			index = i;
			ext = true;
			break;
		}
	}
	if (ext)
	{
		int index1 = 0;
		bool has = false;
		for (int j = 0; j < 10; j++)
		{
			if (FILE_open_list[j].af == NULL)
			{
				index1 = j;
				break;
			}
			if (FILE_open_list[j].af == &FILE_active_list[index])
			{
				has = true;
				break;
			}
		}
		if (has)//�ļ��Ѵ򿪣�
		{
			cout << FILE_active_list[index].dir.DIR_Name << " is already open!" << endl;
			return &FILE_active_list[index].dir;
		}
		else
		{
			OPEN_FILE f;
			f.rw = rw;
			f.af = &FILE_active_list[index];
			FILE_open_list[index1] = f;
			FILE_active_list[index].share_counter++;
			return fp;
		}
	}
	else
	{
		ACTIVE_FILE af;
		af.dir = *fp;
		af.share_counter = 1;
		af.path = path;
		FILE_active_list[index] = af;
		int index1 = 0;
		for (int j = 0; j < 10; j++)
		{
			if (FILE_open_list[j].af == NULL)
			{
				index1 = j;
				break;
			}
		}
		OPEN_FILE f;
		f.rw = rw;
		f.af = &FILE_active_list[index];
		FILE_open_list[index1] = f;
		return fp;
	}
}
//�ر��ļ�
int CloseFile(string path, RootEntry *root, FATTable &tab, DataPart &dp)
{
	if (path.size() == 0)
		return 0;
	RootEntry *fp = NULL;
	int in = 0;
	fp = &Path(path, root, tab, dp,in);
	if (fp == NULL||fp->DIR_Attr==0x01)
	{
		cout << "Path is wrong!" << endl;
		return 0;
	}
	int index = 0;
	for (int i = 0; i < 100; i++)
	{
		if (FILE_active_list[i].path == path)
		{
			index = i;
			break;
		}
	}
	FILE_active_list[index].share_counter--;
	if (FILE_active_list[index].share_counter == 0)
	{
		FILE_active_list[index].path = "";
		FILE_active_list[index].share_counter = 0;
	}
	int index1 = 0;
	for (int j = 0; j < 10; j++)
	{
		if (FILE_open_list[j].af == &FILE_active_list[index])
		{
			index1 = j;
			break;
		}
	}
	FILE_open_list[index1].af = NULL;
	return 1;
}
//�г���Ŀ¼�е�Ŀ¼����
void List_subTree(RootEntry* cur, vector<string>&tree, FATTable &tab, DataPart &dp,int &ji)
{
	if (cur == NULL)
		return;
	vector<unsigned short>clus_list;
	vector<section>data;
	//��Ŀ¼�е�Ŀ¼���״غţ�
	unsigned short tmp = cur->DIR_FstClus;
	while (tmp != 0xFFF&&tmp!=0x000)
	{
		clus_list.push_back(tmp + 31);
		tmp = FindFATClus(tmp, tab);
	}
	for (int i = 0; i < clus_list.size(); i++)
	{
		data.push_back(dp.part[clus_list[i] - 33]);
	}
	vector<RootEntry>sub;//��ǰ��Ŀ¼�����ݼ�����Ŀ¼��
	for (int i = 0; i < data.size(); i++)
	{
		RootEntry *r = make_RootSec(data[i]);//һ�����ݿ鼴һ��������Ŀ¼�
		for (int j = 0; j < 16; j++)
			sub.push_back(r[j]);
	}
	if (sub[2].DIR_Name[0] == '\0')//Ҫ��ȥ�����ı���Ŀ¼����һ��Ŀ¼�������ֽ�Ϊ�յ��ɿ�Ŀ¼����ж���������
		return;
	vector<int>index;
	for (int i = 2; i < sub.size(); i++)
	{
		if (sub[i].DIR_Name[0] == '\0')
			break;
		if (sub[i].DIR_Name[0] != 0xE5 && sub[i].DIR_Attr == 0x10)//�ҵ�Ŀ¼�ļ���
		{
			index.push_back(i);
			string n = "";
			for (int k1 = 0; k1 < 11; k1++)
			{
				n += sub[i].DIR_Name[k1];
			}
			tree.push_back(n);
			//tree.push_back((char *)sub[i].DIR_Name);
		}
	}
	if (index.size() == 0)
		return;
	//tree.push_back("");//��Ϊ�ָ���
	string father = "";
	for (int y = 0; y < 11; y++)
		father += cur->DIR_Name[y];
	string fen = "";
	fen += "/";
	fen += to_string(ji);
	fen += father;
	tree.push_back(fen);//��Ϊ�ָ���
	ji++;
	for (int i = 0; i < index.size(); i++)
	{
		int sji = ji;
		List_subTree(&sub[index[i]], tree, tab, dp,sji);
	}
}
void print(map<string,vector<string>>& lstree,map<string, vector<string>>::iterator lit)
{
	bool flag = true;
	vector<string>sub;
	sub = lit->second;
	int level = lit->first[0] - '0';
	lstree.erase(lit);
	for (int j = 0; j < sub.size(); j++)
	{
		for (int j = 0; j < level; j++)
			cout << '|';
		cout << '-';
		cout << sub[j]<<endl;
		//map<string, vector<string>>::iterator lit;
		string n = "";
		n += level + 1 + '0';
		n += sub[j];
		lit = lstree.find(n);
		if (lit == lstree.end())
			flag = false;
		else
			print(lstree, lit);
	}
	if (flag == false)
		return;
}
//�г����������е�Ŀ¼����
void List_Tree(RootEntry * &root, FATTable &tab, DataPart &dp)//�ļ�����λ0x10ΪĿ¼�ļ���
{
	int num = 0;
	vector<string>tree;
	vector<int>index;
	for (int i = 0; i < 224; i++)
	{
		if (root[i].DIR_Name[0] == '\0')
			break;
		if (root[i].DIR_Name[0]!=0xE5&&root[i].DIR_Attr == 0x10)
		{
			index.push_back(i);
			string n = "";
			for (int k1 = 0; k1 < 11; k1++)
			{
				n += root[i].DIR_Name[k1];
			}
			tree.push_back(n);
		}
	}
	//tree.push_back("");//��Ϊ�ָ���
	tree.push_back("/1Root");//��Ϊ�ָ���
	int ji = 2;
	for (int i = 0; i < index.size(); i++)
	{
		int sji = ji;
		List_subTree(&root[index[i]], tree,tab,dp,sji);
	}
	cout << endl;
	vector<string>::iterator it;
	vector<string>son;
	map<string, vector<string>>lstree;
	map<string, vector<string>>::iterator mit;
	for (it = tree.begin(); it != tree.end();)
	{
		if((*it)[0]=='/')
		{
			string dir = *it;
			dir = dir.substr(1, dir.size() - 1);
			if (lstree.find(dir) == lstree.end())
				lstree[dir] = son;
			tree.erase(tree.begin(), ++it);
			son.clear();
			it = tree.begin();
		}
		else
		{
			son.push_back(*it);
			it++;
		}
	}
	mit = lstree.begin();
	int level = mit->first[0] - '0';
	string d = mit->first.substr(1, mit->first.size() - 1);
	cout << d << endl;
	vector<string>s = mit->second;
	for (int j = 0; j < s.size(); j++)
	{
		for (int j = 0; j < level; j++)
			cout << '|';
		cout << '-';
		cout << s[j] << endl;
		map<string, vector<string>>::iterator lit;
		string n = "";
		n += level + 1 + '0';
		n += s[j];
		lit = lstree.find(n);
		//bool flag = true;
		if (lit != lstree.end())
			print(lstree, lit);
	}
}
//ɾ����Ŀ¼��,ֱ������Ŀ¼��Ӧ�����ݿ����޸ģ���Ϊ·������ʱ���ص�Ŀ¼��ָ�������ݿ��һ���ֵĿ������ı��䲻�ܸı����ݿ飡
//�������path��in���������Ÿ�Ŀ¼�����ݿ��ţ���Ӧdp�еģ�
int del_subEntry(string path, string filename, RootEntry* &root, FATTable &tab, DataPart& dp)//ע�������path��·�������Ĳ�ͬ��pathֻд�����һ����Ŀ¼��
{
	if (path == "/")
		return del_RootEntry(root,filename,tab);
	else
	{
		int in = 0;
		path += filename;
		path += "/";
		bool flag = false;
		RootEntry* tag;
		tag=&Path(path, root, tab, dp, in);
		if (tag == NULL||tag->DIR_Attr==0x01)
		{
			cout << "Path is wrong!";
			cout << endl;
			return -1;
		}
		for (int i = 0; i < 512; i+=32)
		{
			if (i%32==0)
			{
				string s = "";
				for (int j = i; j < 11+i; j++)
				{
					s += dp.part[in].ram512[j];
				}
				if (s == filename)
				{
					dp.part[in].ram512[i] = 0xE5;
					//��Ҫ�Ѹ�Ŀ¼�����ݿ���뵽�������ݿ���
					vector<unsigned short>clus_list;
					unsigned short fst = (unsigned short)dp.part[in].ram512[i + 26] + (unsigned short)dp.part[in].ram512[i + 27] * 256;
					while (fst != 0xFFF && fst != 0x000)
					{
						clus_list.push_back(fst+31);
						fst = FindFATClus(fst, tab);
					}
					for (int x = 0; x < clus_list.size(); x++)
					{
						DP_USE.number.push(clus_list[x]);
					}
					flag = true;
					break;
				}
			}
		}
		if (flag)
			return 1;
		else
			return 0;
	}
}
void Change_FatClus(unsigned short Clusnum,FATTable & tab,unsigned short newnum)
{
	unsigned short  fatNext = 0xfff;
	int  ItemBase;
	ItemBase = Clusnum / 2 * 3;
	if (Clusnum % 2 == 1)
	{
		ItemBase++;
		tab.word[ItemBase + 1] = (unsigned char)(newnum / 16);
		tab.word[ItemBase]= (unsigned char)((unsigned short)tab.word[ItemBase + 1] % 16)+(newnum%16)*16;
	}
	else
	{
		tab.word[ItemBase] = (unsigned char)newnum % (256);
		tab.word[ItemBase + 1] =(unsigned char)((unsigned short)tab.word[ItemBase + 1] / 16) * 16 + newnum / 256;
	}
}
//�ṩһ����������������ַ�������һ���ļ�������Щ������ַ������Ǵ���һ����ͨ�ļ�����Ҫд����Ŀ¼�ļ���
int make_Rootfile(string name, RootEntry* &root,string text)
{
	int index = -1;//������¼��һ����Ŀ¼������
	for (int i = 0; i < 224; i++)
	{
		if (root[i].DIR_Name[0] == '\0')
		{
			index = i;
			break;
		}
		if (root[i].DIR_Name[0] == 0xE5)
		{
			strcpy((char *)root[i].DIR_Name,name.c_str());
			root[i].DIR_Attr = 0x27;
			//�ѵ㣡����ʱ����ô��ã�
			time_t tt = time(NULL);
			struct tm* t = localtime(&tt);
			unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
			unsigned short d = (t->tm_year-63) * 360 + t->tm_mon * 30 + t->tm_mday;
			root[i].DIR_WrtTime = s;
			root[i].DIR_WrtDate = d;
			//�ѵ㣡��ô����FAT��������ݣ�
			root[i].DIR_FileSize = text.size();
			if (text.size() < 512)
			{
				root[i].DIR_FstClus = (DP_USE.number.front()-31);
				Change_FatClus(DP_USE.number.front()- 31, tab, 0xFFF);
				unsigned short temp = 0;
				temp = DP_USE.number.front() - 33;
				DP_USE.number.pop();
				for (int i = 0; i < text.size(); i++)
				{
					dp.part[temp].ram512[i] = text[i];
				}
				for (int i = text.size(); i < 512; i++)
					dp.part[temp].ram512[i] = '\0';
			}
			else
			{
				root[i].DIR_FstClus = (DP_USE.number.front() - 31);
				int kuai = text.size() / 512 + (text.size() % 512 != 0);
				int i = 0;
				unsigned short temp = 0;
				vector<int>list;
				for (i = 0; i < kuai-1; i++)//���ﲻ���ǿ������ݿ鲻�����������Ϊ��ʼʱ�������ݿ����Ķ����ɿ��ã��ӽ�ȥ
				{
					temp = DP_USE.number.front() - 31;
					list.push_back(DP_USE.number.front() - 33);
					DP_USE.number.pop();
					Change_FatClus(temp, tab, DP_USE.number.front()- 31);
				}
				list.push_back(DP_USE.number.front() - 33);//������ݿ�ľ��Կ�ţ�
				Change_FatClus(DP_USE.number.front()- 31, tab, 0xFFF);
				DP_USE.number.pop();
				//�����ݿ��������ļ����ݣ�
				int y = 0;
				int z = 0;
				for (int x = 0, y = 0; x < list.size() && y < 512; x++)
				{
					if (y < 512)
					{
						dp.part[list[x]].ram512[y] = '\0';
					}
					else
					{
						y %= 512;
						x++;
						dp.part[list[x]].ram512[y] = '\0';
					}
					y++;
				}
				for (int x = 0,y=0,z=0; x < text.size()&&y<list.size()&&z<512; x++)
				{
					if (z < 512)
					{
						dp.part[list[y]].ram512[z] = text[x];
					}
					else
					{
						z %= 512;
						y++;
						dp.part[list[y]].ram512[z] = text[x];
					}
					z++;
				}
			}
			break;
		}
	}
	if (index != -1)
	{
		int i = index;
		strcpy((char *)root[i].DIR_Name, name.c_str());
		root[i].DIR_Attr = 0x27;
		//�ѵ㣡����ʱ����ô��ã�
		time_t tt = time(NULL);
		struct tm* t = localtime(&tt);
		unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
		unsigned short d = (t->tm_year-63) * 360 + t->tm_mon * 30 + t->tm_mday;
		root[i].DIR_WrtTime = s;
		root[i].DIR_WrtDate = d;
		//�ѵ㣡��ô����FAT��������ݣ�
		root[i].DIR_FileSize = text.size();
		if (text.size() < 512)
		{
			root[i].DIR_FstClus = (DP_USE.number.front() - 31);
			Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
			unsigned short temp = 0;
			temp = DP_USE.number.front() - 33;
			DP_USE.number.pop();
			for (int i = 0; i < text.size(); i++)
			{
				dp.part[temp].ram512[i] = text[i];
			}
			for (int i = text.size(); i < 512; i++)
				dp.part[temp].ram512[i] = '\0';
		}
		else
		{
			root[i].DIR_FstClus = (DP_USE.number.front() - 31);
			int kuai = text.size() / 512 + (text.size() % 512 != 0);
			int i = 0;
			unsigned short temp = 0;
			vector<int>list;
			for (i = 0; i < kuai - 1; i++)//���ﲻ���ǿ������ݿ鲻�����������Ϊ��ʼʱ�������ݿ����Ķ����ɿ��ã��ӽ�ȥ
			{
				temp = DP_USE.number.front() - 31;
				list.push_back(DP_USE.number.front() - 33);
				DP_USE.number.pop();
				Change_FatClus(temp, tab, DP_USE.number.front() - 31);
			}
			list.push_back(DP_USE.number.front() - 33);//������ݿ�ľ��Կ�ţ�
			Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
			DP_USE.number.pop();
			//�����ݿ��������ļ����ݣ�
			int y = 0;
			int z = 0;
			for (int x = 0, y = 0; x < list.size() && y < 512; x++)
			{
				if (y < 512)
				{
					dp.part[list[x]].ram512[y] = '\0';
				}
				else
				{
					y %= 512;
					x++;
					dp.part[list[x]].ram512[y] = '\0';
				}
				y++;
			}
			for (int x = 0, y = 0, z = 0; x < text.size() && y < list.size() && z < 512; x++)
			{
				if (z < 512)
				{
					dp.part[list[y]].ram512[z] = text[x];
				}
				else
				{
					z %= 512;
					y++;
					dp.part[list[y]].ram512[z] = text[x];
				}
				z++;
			}
		}
	}
	return 1;
}
//����Ŀ¼�д����ļ��������ݣ��ر�Ҫע�⣡Ҫ��dp����ģ�data����subĿ¼���и�û���ã�
int make_subfile(string path, string name, RootEntry* &root, string &text)
{
	if (path == "/")
		return make_Rootfile(name, root,text);
	int in = 0;//in�洢����tagĿ¼�����Ǹ����ݿ飡
	RootEntry* tag = &Path(path, root, tab, dp, in);
	vector<unsigned short>clus_list;
	//��Ŀ¼�е�Ŀ¼���״غţ�
	unsigned short tmp = tag->DIR_FstClus;
	while (tmp != 0xFFF&&tmp!=0x000)
	{
		clus_list.push_back(tmp + 31);
		tmp = FindFATClus(tmp, tab);
	}
	int kuai = -1;
	int index = -1;
	for (int i = 0; i < clus_list.size(); i++)
	{
		for (int j = 0; j < 512; j += 32)
		{
			if (dp.part[clus_list[i] - 33].ram512[j] == '\0')
			{
				kuai = clus_list[i] - 33;
				index = j;
				i == clus_list.size();
				break;
			}
			if (dp.part[clus_list[i] - 33].ram512[j] == 0xE5)
			{
				for (int k = 0; k < name.size(); k++)
				{
					dp.part[clus_list[i] - 33].ram512[j + k] = name[k];
				}
				if (name.size() < 11)
				{
					for(int k=name.size();k<11;k++)
						dp.part[clus_list[i] - 33].ram512[j + k] = '\0';
				}
				dp.part[clus_list[i] - 33].ram512[j + 11] = 0x27;
				time_t tt = time(NULL);
				struct tm* t = localtime(&tt);
				unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
				unsigned short d = (t->tm_year-63) * 360 + t->tm_mon * 30 + t->tm_mday;
				dp.part[clus_list[i] - 33].ram512[j + 22] = (unsigned char)(s % 256);
				dp.part[clus_list[i] - 33].ram512[j + 23] = (unsigned char)(s / 256);
				dp.part[clus_list[i] - 33].ram512[j + 24] = (unsigned char)(d % 256);
				dp.part[clus_list[i] - 33].ram512[j + 25] = (unsigned char)(d / 256);
				//�ѵ㣡��ô�ѻ�õĴ�С��ֳ�һ����char���ͣ���Ҳ�����root���µ�ramFDD144�����ѵ㣡
				int size = text.size();
				dp.part[clus_list[i] - 33].ram512[j + 28] = (unsigned char)(size % 256);
				size /= 256;
				dp.part[clus_list[i] - 33].ram512[j + 29] = (unsigned char)(size % 256);
				size /= 256;
				dp.part[clus_list[i] - 33].ram512[j + 30] = (unsigned char)(size % 256);
				size /= 256;
				dp.part[clus_list[i] - 33].ram512[j + 31] = (unsigned char)(size % 256);
				size /= 256;
				if (text.size() < 512)
				{
					dp.part[clus_list[i]-33].ram512[j+26]= (unsigned char)((DP_USE.number.front() - 31)%256);
					dp.part[clus_list[i] - 33].ram512[j + 27] = (unsigned char)((DP_USE.number.front() - 31) / 256);
					Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
					unsigned short temp = 0;
					temp = DP_USE.number.front() - 33;
					DP_USE.number.pop();
					for (int i = 0; i < text.size(); i++)
					{
						dp.part[temp].ram512[i] = text[i];
					}
					for (int i = text.size();i<512; i++)
						dp.part[temp].ram512[i] = '\0';
				}
				else
				{
					dp.part[clus_list[i] - 33].ram512[j + 26] = (unsigned char)((DP_USE.number.front() - 31) % 256);
					dp.part[clus_list[i] - 33].ram512[j + 27] = (unsigned char)((DP_USE.number.front() - 31) / 256);
					int kuai = text.size() / 512 + (text.size() % 512 != 0);
					int i = 0;
					unsigned short temp = 0;
					vector<int>list;
					for (i = 0; i < kuai - 1; i++)//���ﲻ���ǿ������ݿ鲻�����������Ϊ��ʼʱ�������ݿ����Ķ����ɿ��ã��ӽ�ȥ
					{
						temp = DP_USE.number.front() - 31;
						list.push_back(DP_USE.number.front() - 33);
						DP_USE.number.pop();
						Change_FatClus(temp, tab, DP_USE.number.front() - 31);
					}
					list.push_back(DP_USE.number.front() - 33);
					Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
					DP_USE.number.pop();
					//�����ݿ��������ļ����ݣ�
					int y = 0;
					int z = 0;
					for (int x = 0,y=0; x < list.size()&&y<512; x++)
					{
						if (y < 512)
						{
							dp.part[list[x]].ram512[y] = '\0';
						}
						else
						{
							y %= 512;
							x++;
							dp.part[list[x]].ram512[y] = '\0';
						}
						y++;
					}
					for (int x = 0, y = 0, z = 0; x < text.size() && y < list.size() && z < 512; x++)
					{
						if (z < 512)
						{
							dp.part[list[y]].ram512[z] = text[x];
						}
						else
						{
							z %= 512;
							y++;
							dp.part[list[y]].ram512[z] = text[x];
						}
						z++;
					}
				}
				i = clus_list.size();
				break;
			}
		}
		if (index != -1 && kuai != -1)
		{
			int j = index;
			//i�������¸�ֵ��ԭ���ǣ���ʱ���ڸ����ݿ��ڲ���������iһ�¡�
			for (int k = 0; k < name.size(); k++)
			{
				dp.part[clus_list[i] - 33].ram512[j + k] = name[k];
			}
			if (name.size() < 11)
			{
				for (int k = name.size(); k < 11; k++)
					dp.part[clus_list[i] - 33].ram512[j + k] = '\0';
			}
			dp.part[clus_list[i] - 33].ram512[j + 11] = 0x27;
			time_t tt = time(NULL);
			struct tm* t = localtime(&tt);
			unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
			unsigned short d = (t->tm_year-63) * 360 + t->tm_mon * 30 + t->tm_mday;
			dp.part[clus_list[i] - 33].ram512[j + 22] = (unsigned char)(s % 256);
			dp.part[clus_list[i] - 33].ram512[j + 23] = (unsigned char)(s / 256);
			dp.part[clus_list[i] - 33].ram512[j + 24] = (unsigned char)(d % 256);
			dp.part[clus_list[i] - 33].ram512[j + 25] = (unsigned char)(d / 256);
			//�ѵ㣡��ô�ѻ�õĴ�С��ֳ�һ����char���ͣ���Ҳ�����root���µ�ramFDD144�����ѵ㣡
			int size = text.size();
			dp.part[clus_list[i] - 33].ram512[j + 28] = (unsigned char)(size % 256);
			size /= 256;
			dp.part[clus_list[i] - 33].ram512[j + 29] = (unsigned char)(size % 256);
			size /= 256;
			dp.part[clus_list[i] - 33].ram512[j + 30] = (unsigned char)(size % 256);
			size /= 256;
			dp.part[clus_list[i] - 33].ram512[j + 31] = (unsigned char)(size % 256);
			size /= 256;
			if (text.size() < 512)
			{
				dp.part[clus_list[i] - 33].ram512[j + 26] = (unsigned char)((DP_USE.number.front() - 31) % 256);
				dp.part[clus_list[i] - 33].ram512[j + 27] = (unsigned char)((DP_USE.number.front() - 31) / 256);
				Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
				unsigned short temp = 0;
				temp = DP_USE.number.front() - 33;
				DP_USE.number.pop();
				for (int i = 0; i < text.size(); i++)
				{
					dp.part[temp].ram512[i] = text[i];
				}
				for (int i = text.size(); i < 512; i++)
					dp.part[temp].ram512[i] = '\0';
			}
			else
			{
				dp.part[clus_list[i] - 33].ram512[j + 26] = (unsigned char)((DP_USE.number.front() - 31) % 256);
				dp.part[clus_list[i] - 33].ram512[j + 27] = (unsigned char)((DP_USE.number.front() - 31) / 256);
				int kuai = text.size() / 512 + (text.size() % 512 != 0);
				int i = 0;
				unsigned short temp = 0;
				vector<int>list;
				for (i = 0; i < kuai - 1; i++)//���ﲻ���ǿ������ݿ鲻�����������Ϊ��ʼʱ�������ݿ����Ķ����ɿ��ã��ӽ�ȥ
				{
					temp = DP_USE.number.front() - 31;
					list.push_back(DP_USE.number.front() - 33);
					DP_USE.number.pop();
					Change_FatClus(temp, tab, DP_USE.number.front() - 31);
				}
				list.push_back(DP_USE.number.front() - 33);
				Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
				DP_USE.number.pop();
				//�����ݿ��������ļ����ݣ�
				int y = 0;
				int z = 0;
				for (int x = 0, y = 0; x < list.size() && y < 512; x++)
				{
					if (y < 512)
					{
						dp.part[list[x]].ram512[y] = '\0';
					}
					else
					{
						y %= 512;
						x++;
						dp.part[list[x]].ram512[y] = '\0';
					}
					y++;
				}
				for (int x = 0, y = 0, z = 0; x < text.size() && y < list.size() && z < 512; x++)
				{
					if (z < 512)
					{
						dp.part[list[y]].ram512[z] = text[x];
					}
					else
					{
						z %= 512;
						y++;
						dp.part[list[y]].ram512[z] = text[x];
					}
					z++;
				}
			}
			break;
		}
	}
	return 1;
}
//��ʾһ���ļ�������
void display(string path, RootEntry *&root, FATTable & tab, DataPart &dp)//�����·��Ҫ��/��β����·����������ͬ��
{
	RootEntry * tag;
	int in = 0;
	tag = &Path(path, root, tab, dp,in);//���ص���ָ��ָ���ļ�Ŀ¼���ָ�룬in�����Ŀ¼����ڵĶ�Ӧ���ݿ��ţ�
	if (tag == NULL||tag->DIR_Attr==0x01)
	{
		cout << "Path is wrong!" << endl;
		return;
	}
	vector<unsigned short>clus_list;
	vector<section>data;//����Ŀ���ļ��洢���ݵ����ݿ飡
	//Ŀ���ļ����״غţ�
	unsigned short tmp = tag->DIR_FstClus;
	int size = tag->DIR_FileSize;
	while (tmp != 0xFFF&&tmp!=0x000)//����ǿ��ļ��״غ�Ϊ0xFFF
	{
		clus_list.push_back(tmp + 31);
		tmp = FindFATClus(tmp, tab);
	}
	for (int i = 0; i < clus_list.size(); i++)
	{
		data.push_back(dp.part[clus_list[i] - 33]);
	}
	for (int i = 0; i < data.size(); i++)
	{
		for (int j = 0; j < size; j++)
		{
			cout << data[i].ram512[j];
		}
	}
}
//��ʾ����������Ϣ
fat12header& get_Head(section* & ramFDD144)
{
	fat12header head;
	for (int i = 3; i < 62; i++)
	{
		if (i < 11)
			head.BS_OEMName[i - 3] = ramFDD144[0].ram512[i];
		else if (i == 11)
		{
			head.BPB_BytesPetSec = unsigned short(ramFDD144[0].ram512[i]) + unsigned short(ramFDD144[0].ram512[i + 1]) * 256;
			i++;
		}
		else if (i == 13)
			head.BPB_SecPerClus = ramFDD144[0].ram512[i];
		else if (i == 14)
		{
			head.BPB_RsvdSecCnt = unsigned short(ramFDD144[0].ram512[i]) + unsigned short(ramFDD144[0].ram512[i + 1]) * 256;
			i++;
		}
		else if (i == 16)
			head.BPB_NumFATs = ramFDD144[0].ram512[i];
		else if (i == 17)
		{
			head.BPB_RootEntCnt = unsigned short(ramFDD144[0].ram512[i]) + unsigned short(ramFDD144[0].ram512[i + 1]) * 256;
			i++;
		}
		else if (i == 19)
		{
			head.BPB_TotSec16 = unsigned short(ramFDD144[0].ram512[i]) + unsigned short(ramFDD144[0].ram512[i + 1]) * 256;
			i++;
		}
		else if (i == 21)
			head.BPB_Media = ramFDD144[0].ram512[i];
		else if (i == 22)
		{
			head.BPB_FATSz16= unsigned short(ramFDD144[0].ram512[i]) + unsigned short(ramFDD144[0].ram512[i + 1]) * 256;
			i++;
		}
		else if (i == 24)
		{
			head.BPB_SecPerTrk = unsigned short(ramFDD144[0].ram512[i]) + unsigned short(ramFDD144[0].ram512[i + 1]) * 256;
			i++;
		}
		else if (i == 26)
		{
			head.BPB_NumHeads= unsigned short(ramFDD144[0].ram512[i]) + unsigned short(ramFDD144[0].ram512[i + 1]) * 256;
			i++;
		}
		else if (i==28)
		{
			head.BPB_HiddSec= unsigned int(ramFDD144[0].ram512[i]) + unsigned int(ramFDD144[0].ram512[i + 1]) * 256 + unsigned int(ramFDD144[0].ram512[i + 2])*pow(2, 16) + unsigned int(ramFDD144[0].ram512[i + 3])*pow(2, 24);
			i += 3;
		}
		else if (i == 32)
		{
			head.BPB_TotSec32= unsigned int(ramFDD144[0].ram512[i]) + unsigned int(ramFDD144[0].ram512[i + 1]) * 256 + unsigned int(ramFDD144[0].ram512[i + 2])*pow(2, 16) + unsigned int(ramFDD144[0].ram512[i + 3])*pow(2, 24);
			i += 3;
		}
		else if (i == 36)
		{
			head.BS_DrvNum = ramFDD144[0].ram512[i];
		}
		else if (i == 38)
		{
			head.BS_BootSig = ramFDD144[0].ram512[i];
		}
		else if (i == 39)
		{
			head.BS_VolID= unsigned int(ramFDD144[0].ram512[i]) + unsigned int(ramFDD144[0].ram512[i + 1]) * 256 + unsigned int(ramFDD144[0].ram512[i + 2])*pow(2, 16) + unsigned int(ramFDD144[0].ram512[i + 3])*pow(2, 24);
			i += 3;
		}
		else if (i >= 43 && i < 54)
		{
			head.BS_VolLab[i - 43] = ramFDD144[0].ram512[i];
		}
		else if (i >= 54 && i < 62)
		{
			head.BS_FileSysType[i - 54] = ramFDD144[0].ram512[i];
		}
	}
	return head;
}
void Dis_head(fat12header& head)
{
	cout << "��������" << head.BS_OEMName << endl;
	cout << "ÿ�����ֽ�����" << head.BPB_BytesPetSec << endl;
	cout << "ÿ����������" << (unsigned short)head.BPB_SecPerClus << endl;
	cout << "Boot��¼ռ����������" << head.BPB_RsvdSecCnt << endl;
	cout << "FAT������" << (unsigned short)head.BPB_NumFATs<< endl;
	cout << "��Ŀ¼�ļ������ֵ��" << head.BPB_RootEntCnt << endl;
	cout << "����������" << head.BPB_TotSec16 << endl;
	cout << "������������" << head.BPB_Media << endl;
	cout << "ÿFAT��������" << head.BPB_FATSz16 << endl;
	cout << "ÿ�ŵ���������" << head.BPB_SecPerTrk << endl;
	cout << "��ͷ����" << head.BPB_NumHeads << endl;
	cout << "������������" << head.BPB_HiddSec << endl;
	cout << "ֵ��¼��������" << head.BPB_TotSec32 << endl;
	cout << "�ж�13�������ţ�" <<(unsigned short) head.BS_DrvNum << endl;
	cout << "��չ������¼��" << (unsigned short)head.BS_BootSig << endl;
	cout << "�����кţ�" << head.BS_VolID << endl;
	cout << "��꣺";
	for (int i = 0; i < 11; i++)
		cout << head.BS_VolLab[i];
	cout << endl;
	cout << "�ļ�ϵͳ���ͣ�" ;
	for (int i = 0; i < 8; i++)
		cout << head.BS_FileSysType[i];
	cout << endl;
}
//������Ŀ¼��


//dir������Ŀ¼���Բ������ڸ�Ŀ¼�����Դ�·���������г�·���ж�Ӧ�����һ����Ŀ¼��Ŀ¼���ݣ�
//�г���ǰĿ¼�µ�Ŀ¼���ݣ�
void  List_subEntry(string &path, RootEntry* & root, FATTable & tab, DataPart& dp)
{
	if (path== "/")
		List_Root(root);
	else
	{
		int in = 0;
		RootEntry *tag = &Path(path, root, tab, dp, in);
		if (tag == NULL||tag->DIR_Attr==0x01)
		{
			cout << "Path is wrong!" << endl;
			return;
		}
		vector<unsigned short>clus_list;//��Ŀ¼�ļ��İ������ݿ�ţ�
		vector<section>data;//����Ŀ���ļ��洢���ݵ����ݿ飡
		//Ŀ���ļ����״غţ�
		unsigned short tmp = tag->DIR_FstClus;
		while (tmp != 0xFFF&&tmp!=0x000)//����ǿ��ļ��״غ�Ϊ0xFFF
		{
			clus_list.push_back(tmp + 31);
			tmp = FindFATClus(tmp, tab);
		}
		for (int i = 0; i < clus_list.size(); i++)
		{
			data.push_back(dp.part[clus_list[i] - 33]);
		}
		vector<RootEntry>sub;//��ǰĿ¼�����ݼ�����Ŀ¼��
		for (int i = 0; i < data.size(); i++)
		{
			RootEntry *r = make_RootSec(data[i]);//һ�����ݿ鼴һ��������Ŀ¼�
			for (int j = 0; j < 16; j++)
				sub.push_back(r[j]);
		}
		for (int i = 0; i < sub.size(); i++)
		{
			if (sub[i].DIR_Name[0] == '\0')//��ɾ���ļ�����ʾ
				break;
			else if(sub[i].DIR_Name[0]!=0xE5&&i>=2)
			{
				List_RootEntry(sub[i]);
				cout << endl;
			}
		}
	}
}
//������Ŀ¼�ļ�
int make_Rootdir(string name, RootEntry* &root)
{
	int index = -1;//������¼��һ����Ŀ¼������
	for (int i = 0; i < 224; i++)
	{
		if (root[i].DIR_Name[0] == '\0')
		{
			index = i;
			break;
		}
		if (root[i].DIR_Name[0] == 0xE5)
		{
			strcpy((char *)root[i].DIR_Name, name.c_str());
			root[i].DIR_Attr = 0x10;
			//�ѵ㣡����ʱ����ô��ã�
			time_t tt = time(NULL);
			struct tm* t = localtime(&tt);
			unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
			unsigned short d = (t->tm_year - 63) * 360 + t->tm_mon * 30 + t->tm_mday;
			root[i].DIR_WrtTime = s;
			root[i].DIR_WrtDate = d;
			//�ѵ㣡��ô����FAT��������ݣ�
			root[i].DIR_FstClus = (DP_USE.number.front() - 31);
			Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
			unsigned short temp = 0;
			temp = DP_USE.number.front() - 33;
			DP_USE.number.pop();
			for (int i = 0; i < 512; i++)
				dp.part[temp].ram512[i] = '\0';
			string fa = ".";
			string me = "..";
			while (fa.size() != 11)
				fa += " ";
			while (me.size() != 11)
				me += " ";
			int start = 0;
			for (int x = 0; x < 11; x++)
			{
				dp.part[temp].ram512[start + x] = fa[x];
			}
			dp.part[temp].ram512[start + 11] = 0x10;
			start = 32;
			for (int x = 0; x < 11; x++)
			{
				dp.part[temp].ram512[start + x] = fa[x];
			}
			dp.part[temp].ram512[start + 11] = 0x10;
			break;
		}
	}
	if (index != -1)
	{
		int i = index;
		strcpy((char *)root[i].DIR_Name, name.c_str());
		root[i].DIR_Attr = 0x10;
		//�ѵ㣡����ʱ����ô��ã�
		time_t tt = time(NULL);
		struct tm* t = localtime(&tt);
		unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
		unsigned short d = (t->tm_year - 63) * 360 + t->tm_mon * 30 + t->tm_mday;
		root[i].DIR_WrtTime = s;
		root[i].DIR_WrtDate = d;
		//�ѵ㣡��ô����FAT��������ݣ�
		root[i].DIR_FstClus = (DP_USE.number.front() - 31);
		Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
		unsigned short temp = 0;
		temp = DP_USE.number.front() - 33;
		DP_USE.number.pop();
		for (int i = 0; i < 512; i++)
			dp.part[temp].ram512[i] = '\0';
		string fa = ".";
		string me = "..";
		while (fa.size() != 11)
			fa += " ";
		while (me.size() != 11)
			me += " ";
		int start = 0;
		for (int x = 0; x < 11; x++)
		{
			dp.part[temp].ram512[start + x] = fa[x];
		}
		dp.part[temp].ram512[start + 11] = 0x10;
		start = 32;
		for (int x = 0; x < 11; x++)
		{
			dp.part[temp].ram512[start + x] = fa[x];
		}
		dp.part[temp].ram512[start + 11] = 0x10;
	}
	return 1;
}
int make_subdir(string path, string name, RootEntry* &root)
{
	if (path == "/")
		return make_Rootdir(name, root);
	int in = 0;//in�洢����tagĿ¼�����Ǹ����ݿ飡
	RootEntry* tag = &Path(path, root, tab, dp, in);
	vector<unsigned short>clus_list;
	//��Ŀ¼�е�Ŀ¼���״غţ�
	unsigned short tmp = tag->DIR_FstClus;
	while (tmp != 0xFFF && tmp != 0x000)
	{
		clus_list.push_back(tmp + 31);
		tmp = FindFATClus(tmp, tab);
	}
	int kuai = -1;
	int index = -1;
	for (int i = 0; i < clus_list.size(); i++)
	{
		for (int j = 0; j < 512; j += 32)
		{
			if (dp.part[clus_list[i] - 33].ram512[j] == '\0')
			{
				kuai = clus_list[i] - 33;
				index = j;
				i == clus_list.size();
				break;
			}
			if (dp.part[clus_list[i] - 33].ram512[j] == 0xE5)
			{
				for (int k = 0; k < name.size(); k++)
				{
					dp.part[clus_list[i] - 33].ram512[j + k] = name[k];
				}
				if (name.size() < 11)
				{
					for (int k = name.size(); k < 11; k++)
						dp.part[clus_list[i] - 33].ram512[j + k] = '\0';
				}
				dp.part[clus_list[i] - 33].ram512[j + 11] = 0x10;
				time_t tt = time(NULL);
				struct tm* t = localtime(&tt);
				unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
				unsigned short d = (t->tm_year - 63) * 360 + t->tm_mon * 30 + t->tm_mday;
				dp.part[clus_list[i] - 33].ram512[j + 22] = (unsigned char)(s % 256);
				dp.part[clus_list[i] - 33].ram512[j + 23] = (unsigned char)(s / 256);
				dp.part[clus_list[i] - 33].ram512[j + 24] = (unsigned char)(d % 256);
				dp.part[clus_list[i] - 33].ram512[j + 25] = (unsigned char)(d / 256);
				//�ѵ㣡��ô�ѻ�õĴ�С��ֳ�һ����char���ͣ���Ҳ�����root���µ�ramFDD144�����ѵ㣡
				dp.part[clus_list[i] - 33].ram512[j + 26] = (unsigned char)((DP_USE.number.front() - 31) % 256);
				dp.part[clus_list[i] - 33].ram512[j + 27] = (unsigned char)((DP_USE.number.front() - 31) / 256);
				Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
				unsigned short temp = 0;
				temp = DP_USE.number.front() - 33;
				DP_USE.number.pop();
				for (int i = 0; i < 512; i++)
					dp.part[temp].ram512[i] = '\0';
				string fa = ".";
				string me = "..";
				while (fa.size() != 11)
					fa += " ";
				while (me.size() != 11)
					me += " ";
				int start = 0;
				for (int x = 0; x < 11; x++)
				{
					dp.part[temp].ram512[start + x] = fa[x];
				}
				dp.part[temp].ram512[start + 11] = 0x10;
				start = 32;
				for (int x = 0; x < 11; x++)
				{
					dp.part[temp].ram512[start + x] = fa[x];
				}
				dp.part[temp].ram512[start + 11] = 0x10;
				i = clus_list.size();
				break;
			}
		}
		if (index != -1 && kuai != -1)
		{
			int j = index;
			//i�������¸�ֵ��ԭ���ǣ���ʱ���ڸ����ݿ��ڲ���������iһ�¡�
			for (int k = 0; k < name.size(); k++)
			{
				dp.part[clus_list[i] - 33].ram512[j + k] = name[k];
			}
			if (name.size() < 11)
			{
				for (int k = name.size(); k < 11; k++)
					dp.part[clus_list[i] - 33].ram512[j + k] = '\0';
			}
			dp.part[clus_list[i] - 33].ram512[j + 11] = 0x10;
			time_t tt = time(NULL);
			struct tm* t = localtime(&tt);
			unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
			unsigned short d = (t->tm_year - 63) * 360 + t->tm_mon * 30 + t->tm_mday;
			dp.part[clus_list[i] - 33].ram512[j + 22] = (unsigned char)(s % 256);
			dp.part[clus_list[i] - 33].ram512[j + 23] = (unsigned char)(s / 256);
			dp.part[clus_list[i] - 33].ram512[j + 24] = (unsigned char)(d % 256);
			dp.part[clus_list[i] - 33].ram512[j + 25] = (unsigned char)(d / 256);
			//�ѵ㣡��ô�ѻ�õĴ�С��ֳ�һ����char���ͣ���Ҳ�����root���µ�ramFDD144�����ѵ㣡
			dp.part[clus_list[i] - 33].ram512[j + 26] = (unsigned char)((DP_USE.number.front() - 31) % 256);
			dp.part[clus_list[i] - 33].ram512[j + 27] = (unsigned char)((DP_USE.number.front() - 31) / 256);
			Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
			unsigned short temp = 0;
			temp = DP_USE.number.front() - 33;
			DP_USE.number.pop();
			for (int i = 0; i < 512; i++)
				dp.part[temp].ram512[i] = '\0';
			string fa = ".";
			string me = "..";
			while (fa.size() != 11)
				fa += " ";
			while (me.size() != 11)
				me += " ";
			int start = 0;
			for (int x = 0; x < 11; x++)
			{
				dp.part[temp].ram512[start + x] = fa[x];
			}
			dp.part[temp].ram512[start + 11] = 0x10;
			start = 32;
			for (int x = 0; x < 11; x++)
			{
				dp.part[temp].ram512[start + x] = fa[x];
			}
			dp.part[temp].ram512[start + 11] = 0x10;
			break;
		}
	}
	return 1;
}

void WB(section* ramFDD144,RootEntry* & root,FATTable &tab,DataPart & dp)
{
	ofstream out;
	out.open("dossys.img", ios::out|ios::binary);
	//д��������
	for (int i = 0; i < 512; i++)
		out.put(ramFDD144[0].ram512[i]);
		//out <<ramFDD144[0].ram512[i];
	//д��FAT��
	for (int i = 0; i < 4608; i++)
		out.put(tab.word[i]);
	//out << (char)tab.word[i];
	for (int i = 0; i < 4608; i++)
		out.put(tab.word[i]);
	//out << (char)tab.word[i];
	//д�ظ�Ŀ¼��
	for (int i = 0; i < 224; i++)
	{
		for (int j = 0; j < 11; j++)
			out.put(root[i].DIR_Name[j]);
			//out <<root[i].DIR_Name[j];
		out.put(root[i].DIR_Attr);
		//out <<root[i].DIR_Attr;
		for (int j = 0; j < 10; j++)
			out.put('\0');
			//out <<root[i].Reserve[j];
		unsigned char a = root[i].DIR_WrtTime % 256;
		out.put(a);
		out.put((unsigned char)(root[i].DIR_WrtTime / 256));
		out.put((unsigned char)(root[i].DIR_WrtDate % 256));
		out.put((unsigned char)(root[i].DIR_WrtDate / 256));
		out.put((unsigned char)(root[i].DIR_FstClus % 256));
		out.put((unsigned char)(root[i].DIR_FstClus / 256));

		/*out << (char)(root[i].DIR_WrtTime % 256);
		out << (char)(root[i].DIR_WrtTime / 256);
		out << (char)(root[i].DIR_WrtDate% 256);
		out << (char)(root[i].DIR_WrtDate/ 256);
		out << (char)(root[i].DIR_FstClus % 256);
		out << (char)(root[i].DIR_FstClus/ 256);*/
		int temp = root[i].DIR_FileSize;
		out.put((unsigned char)(temp % 256));
		//out << (char)(temp% 256);
		temp /= 256;
		out.put((unsigned char)(temp % 256));
		//out << (char)(temp% 256);
		temp /= 256;
		out.put((unsigned char)(temp % 256));
		//out << (char)(temp % 256);
		out.put((unsigned char)(temp / 256));
		//out << (char)(temp / 256);
	}
	//д����ͨ������
	for (int i = 0; i < 2847; i++)
	{
		for (int j = 0; j < 512; j++)
		{
			out.put(dp.part[i].ram512[j]);
			//out << (char)dp.part[i].ram512[j];
		}
	}
	out.close();
}
