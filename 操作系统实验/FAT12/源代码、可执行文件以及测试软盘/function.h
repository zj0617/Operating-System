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
//记得要修改的时候要按引用传递！！！！！这样得到的head、root、tab、datapart才是改好的！然后再更改到大数组里，最后写回软盘(转换成int！)！
bool Header_Format(section * &ramFDD144)//检查首扇区内容是否符合FAT12格式 只要结尾即可？
{
	fat12header header;
	if (ramFDD144 == NULL)
		return false;
	return (ramFDD144[0].ram512[510] == 0x55 && ramFDD144[0].ram512[511] == 0xAA);
}
//读取根目录区一个扇区的目录项
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
			r[i].DIR_WrtTime=unsigned short(s.ram512[k])+unsigned short(s.ram512[k+1])*256;//小端方式！
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
//转换时间
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
//转换日期,天为单位,为了简化以每个月30天计算
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
//列出fdd144虚拟软盘中根目录文件目录项内容。
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
//从整个软盘中获得根目录区,以224个目录项的形式存储
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
//列出根目录区所有目录内容
void List_Root(RootEntry *&root)
{
	for (int i = 0; i < 224; i++)
	{
		if (root[i].DIR_Name[0] == '\0')//空目录项或已删除文件不显示
			break;
		else if(root[i].DIR_Name[0] != 229)
		{
			List_RootEntry(root[i]);
			cout << endl;
		}
	}
}
//根据簇号找到对应簇中的内容,有待验证！
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


//删除根目录的一个指定文件,root更改之后需要写回ram144中！类似的%32即可！记得要写回ram!！同时记得要修改的时候要按引用传递！
int del_RootEntry(RootEntry * &root, string filename,FATTable& tab)
{
	//这里需要先判断文件是否打开！
	bool flag = false;
	for (int i = 0; i < 224; i++)
	{
		if (root[i].DIR_Name[0] == '\0')//空目录项跳出
			break;
		string name = "";
		for (int j = 0; j < 11; j++)
		{
			name += root[i].DIR_Name[j];
		}
		if (name == filename)//比较匹配文件名
		{
			root[i].DIR_Name[0] = 229;//将目录项首字符改成E5
			//还要将删除目录项的数据簇簇号放入可用数据块队列中
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
	if (flag)//成功删除
		return 1;
	else
		return 0;//未找到文件，删除失败
}

//实现按路径名操作文件，路径分析算法！注意！：这里路径分析返回的指针不是指向原来数据区的！所以如果只是显示目录可以这样，如果需要更改值需要找到对应的数据块，整块要修改到原来数据区中！
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
	for (i = 1; i < subpath.size(); i++)//以A:/开头！
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
     //子目录中的目录项首簇号；
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
	vector<RootEntry>sub;//当前目录的内容即所有目录项
	for (int i = 0; i < data.size(); i++)
	{
		RootEntry *r = make_RootSec(data[i]);//一个数据块即一个扇区的目录项！
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
	in = clus_list[i / 16] - 33;//匹配的子目录项对应的数据区的扇区号！
	if (spath == "/")
		return *scur;
	return Path_sub(spath, scur, tab, dp,in);
}
RootEntry Path(string &filepath,RootEntry * &cur,FATTable &tab,DataPart &dp,int &in)//根目录中的路径匹配！
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
	for (i = 1; i < filepath.size(); i++)//以/开头！
	{
		if (filepath[i] == '/')//这里这样所以输入路径时要以/结尾！
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
//打开文件
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
		if (has)//文件已打开！
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
//关闭文件
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
//列出子目录中的目录树！
void List_subTree(RootEntry* cur, vector<string>&tree, FATTable &tab, DataPart &dp,int &ji)
{
	if (cur == NULL)
		return;
	vector<unsigned short>clus_list;
	vector<section>data;
	//子目录中的目录项首簇号；
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
	vector<RootEntry>sub;//当前子目录的内容即所有目录项
	for (int i = 0; i < data.size(); i++)
	{
		RootEntry *r = make_RootSec(data[i]);//一个数据块即一个扇区的目录项！
		for (int j = 0; j < 16; j++)
			sub.push_back(r[j]);
	}
	if (sub[2].DIR_Name[0] == '\0')//要除去包括的本级目录和上一级目录！把首字节为空当成空目录项的判定条件！！
		return;
	vector<int>index;
	for (int i = 2; i < sub.size(); i++)
	{
		if (sub[i].DIR_Name[0] == '\0')
			break;
		if (sub[i].DIR_Name[0] != 0xE5 && sub[i].DIR_Attr == 0x10)//找到目录文件！
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
	//tree.push_back("");//作为分隔符
	string father = "";
	for (int y = 0; y < 11; y++)
		father += cur->DIR_Name[y];
	string fen = "";
	fen += "/";
	fen += to_string(ji);
	fen += father;
	tree.push_back(fen);//作为分隔符
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
//列出虚拟软盘中的目录树！
void List_Tree(RootEntry * &root, FATTable &tab, DataPart &dp)//文件属性位0x10为目录文件！
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
	//tree.push_back("");//作为分隔符
	tree.push_back("/1Root");//作为分隔符
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
//删除子目录项,直接在子目录对应的数据块中修改！因为路径分析时返回的目录项指针是数据块的一部分的拷贝，改变其不能改变数据块！
//因此利用path的in变量保存存放该目录的数据块块号！对应dp中的！
int del_subEntry(string path, string filename, RootEntry* &root, FATTable &tab, DataPart& dp)//注意这里的path与路径分析的不同，path只写到最后一级子目录！
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
					//还要把该目录的数据块加入到可用数据块中
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
//提供一个输入框，输入任意字符，创建一个文件保存这些输入的字符。就是创建一个普通文件！还要写创建目录文件！
int make_Rootfile(string name, RootEntry* &root,string text)
{
	int index = -1;//用来记录第一个空目录项的序号
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
			//难点！日期时间怎么获得？
			time_t tt = time(NULL);
			struct tm* t = localtime(&tt);
			unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
			unsigned short d = (t->tm_year-63) * 360 + t->tm_mon * 30 + t->tm_mday;
			root[i].DIR_WrtTime = s;
			root[i].DIR_WrtDate = d;
			//难点！怎么更改FAT表项的内容！
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
				for (i = 0; i < kuai-1; i++)//这里不考虑可用数据块不够的情况，因为初始时候会把数据块后面的都当成可用！加进去
				{
					temp = DP_USE.number.front() - 31;
					list.push_back(DP_USE.number.front() - 33);
					DP_USE.number.pop();
					Change_FatClus(temp, tab, DP_USE.number.front()- 31);
				}
				list.push_back(DP_USE.number.front() - 33);//存放数据块的绝对块号！
				Change_FatClus(DP_USE.number.front()- 31, tab, 0xFFF);
				DP_USE.number.pop();
				//将数据块来保存文件内容！
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
		//难点！日期时间怎么获得？
		time_t tt = time(NULL);
		struct tm* t = localtime(&tt);
		unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
		unsigned short d = (t->tm_year-63) * 360 + t->tm_mon * 30 + t->tm_mday;
		root[i].DIR_WrtTime = s;
		root[i].DIR_WrtDate = d;
		//难点！怎么更改FAT表项的内容！
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
			for (i = 0; i < kuai - 1; i++)//这里不考虑可用数据块不够的情况，因为初始时候会把数据块后面的都当成可用！加进去
			{
				temp = DP_USE.number.front() - 31;
				list.push_back(DP_USE.number.front() - 33);
				DP_USE.number.pop();
				Change_FatClus(temp, tab, DP_USE.number.front() - 31);
			}
			list.push_back(DP_USE.number.front() - 33);//存放数据块的绝对块号！
			Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
			DP_USE.number.pop();
			//将数据块来保存文件内容！
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
//在子目录中创建文件保存内容！特别要注意！要在dp里面改，data或者sub目录项中改没有用！
int make_subfile(string path, string name, RootEntry* &root, string &text)
{
	if (path == "/")
		return make_Rootfile(name, root,text);
	int in = 0;//in存储的是tag目录项在那个数据块！
	RootEntry* tag = &Path(path, root, tab, dp, in);
	vector<unsigned short>clus_list;
	//子目录中的目录项首簇号；
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
				//难点！怎么把获得的大小拆分成一个个char类型！这也是最后root更新到ramFDD144的重难点！
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
					for (i = 0; i < kuai - 1; i++)//这里不考虑可用数据块不够的情况，因为初始时候会把数据块后面的都当成可用！加进去
					{
						temp = DP_USE.number.front() - 31;
						list.push_back(DP_USE.number.front() - 33);
						DP_USE.number.pop();
						Change_FatClus(temp, tab, DP_USE.number.front() - 31);
					}
					list.push_back(DP_USE.number.front() - 33);
					Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
					DP_USE.number.pop();
					//将数据块来保存文件内容！
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
			//i不用重新赋值的原因是，此时仍在该数据块内操作！所以i一致。
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
			//难点！怎么把获得的大小拆分成一个个char类型！这也是最后root更新到ramFDD144的重难点！
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
				for (i = 0; i < kuai - 1; i++)//这里不考虑可用数据块不够的情况，因为初始时候会把数据块后面的都当成可用！加进去
				{
					temp = DP_USE.number.front() - 31;
					list.push_back(DP_USE.number.front() - 33);
					DP_USE.number.pop();
					Change_FatClus(temp, tab, DP_USE.number.front() - 31);
				}
				list.push_back(DP_USE.number.front() - 33);
				Change_FatClus(DP_USE.number.front() - 31, tab, 0xFFF);
				DP_USE.number.pop();
				//将数据块来保存文件内容！
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
//显示一个文件的内容
void display(string path, RootEntry *&root, FATTable & tab, DataPart &dp)//这里的路径要以/结尾！与路径分析的相同！
{
	RootEntry * tag;
	int in = 0;
	tag = &Path(path, root, tab, dp,in);//返回的是指向指定文件目录项的指针，in保存该目录项存在的对应数据块块号！
	if (tag == NULL||tag->DIR_Attr==0x01)
	{
		cout << "Path is wrong!" << endl;
		return;
	}
	vector<unsigned short>clus_list;
	vector<section>data;//保存目标文件存储内容的数据块！
	//目标文件的首簇号；
	unsigned short tmp = tag->DIR_FstClus;
	int size = tag->DIR_FileSize;
	while (tmp != 0xFFF&&tmp!=0x000)//如果是空文件首簇号为0xFFF
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
//显示首扇区的信息
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
	cout << "厂商名：" << head.BS_OEMName << endl;
	cout << "每扇区字节数：" << head.BPB_BytesPetSec << endl;
	cout << "每簇扇区数：" << (unsigned short)head.BPB_SecPerClus << endl;
	cout << "Boot记录占用扇区数：" << head.BPB_RsvdSecCnt << endl;
	cout << "FAT表数：" << (unsigned short)head.BPB_NumFATs<< endl;
	cout << "根目录文件数最大值：" << head.BPB_RootEntCnt << endl;
	cout << "扇区总数：" << head.BPB_TotSec16 << endl;
	cout << "介质描述符：" << head.BPB_Media << endl;
	cout << "每FAT扇区数：" << head.BPB_FATSz16 << endl;
	cout << "每磁道扇区数：" << head.BPB_SecPerTrk << endl;
	cout << "磁头数：" << head.BPB_NumHeads << endl;
	cout << "隐藏扇区数：" << head.BPB_HiddSec << endl;
	cout << "值记录扇区数：" << head.BPB_TotSec32 << endl;
	cout << "中断13驱动器号：" <<(unsigned short) head.BS_DrvNum << endl;
	cout << "扩展引导记录：" << (unsigned short)head.BS_BootSig << endl;
	cout << "卷序列号：" << head.BS_VolID << endl;
	cout << "卷标：";
	for (int i = 0; i < 11; i++)
		cout << head.BS_VolLab[i];
	cout << endl;
	cout << "文件系统类型：" ;
	for (int i = 0; i < 8; i++)
		cout << head.BS_FileSysType[i];
	cout << endl;
}
//创建子目录！


//dir命令列目录可以不局限于根目录，可以从路径出发，列出路径中对应的最后一级子目录的目录内容！
//列出当前目录下的目录内容！
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
		vector<unsigned short>clus_list;//子目录文件的包含数据块号！
		vector<section>data;//保存目标文件存储内容的数据块！
		//目标文件的首簇号；
		unsigned short tmp = tag->DIR_FstClus;
		while (tmp != 0xFFF&&tmp!=0x000)//如果是空文件首簇号为0xFFF
		{
			clus_list.push_back(tmp + 31);
			tmp = FindFATClus(tmp, tab);
		}
		for (int i = 0; i < clus_list.size(); i++)
		{
			data.push_back(dp.part[clus_list[i] - 33]);
		}
		vector<RootEntry>sub;//当前目录的内容即所有目录项
		for (int i = 0; i < data.size(); i++)
		{
			RootEntry *r = make_RootSec(data[i]);//一个数据块即一个扇区的目录项！
			for (int j = 0; j < 16; j++)
				sub.push_back(r[j]);
		}
		for (int i = 0; i < sub.size(); i++)
		{
			if (sub[i].DIR_Name[0] == '\0')//已删除文件不显示
				break;
			else if(sub[i].DIR_Name[0]!=0xE5&&i>=2)
			{
				List_RootEntry(sub[i]);
				cout << endl;
			}
		}
	}
}
//创建子目录文件
int make_Rootdir(string name, RootEntry* &root)
{
	int index = -1;//用来记录第一个空目录项的序号
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
			//难点！日期时间怎么获得？
			time_t tt = time(NULL);
			struct tm* t = localtime(&tt);
			unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
			unsigned short d = (t->tm_year - 63) * 360 + t->tm_mon * 30 + t->tm_mday;
			root[i].DIR_WrtTime = s;
			root[i].DIR_WrtDate = d;
			//难点！怎么更改FAT表项的内容！
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
		//难点！日期时间怎么获得？
		time_t tt = time(NULL);
		struct tm* t = localtime(&tt);
		unsigned short s = t->tm_hour * 3600 + t->tm_min * 60 + t->tm_sec;
		unsigned short d = (t->tm_year - 63) * 360 + t->tm_mon * 30 + t->tm_mday;
		root[i].DIR_WrtTime = s;
		root[i].DIR_WrtDate = d;
		//难点！怎么更改FAT表项的内容！
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
	int in = 0;//in存储的是tag目录项在那个数据块！
	RootEntry* tag = &Path(path, root, tab, dp, in);
	vector<unsigned short>clus_list;
	//子目录中的目录项首簇号；
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
				//难点！怎么把获得的大小拆分成一个个char类型！这也是最后root更新到ramFDD144的重难点！
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
			//i不用重新赋值的原因是，此时仍在该数据块内操作！所以i一致。
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
			//难点！怎么把获得的大小拆分成一个个char类型！这也是最后root更新到ramFDD144的重难点！
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
	//写回首扇区
	for (int i = 0; i < 512; i++)
		out.put(ramFDD144[0].ram512[i]);
		//out <<ramFDD144[0].ram512[i];
	//写回FAT表
	for (int i = 0; i < 4608; i++)
		out.put(tab.word[i]);
	//out << (char)tab.word[i];
	for (int i = 0; i < 4608; i++)
		out.put(tab.word[i]);
	//out << (char)tab.word[i];
	//写回根目录区
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
	//写回普通数据区
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
