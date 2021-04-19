#include <iostream>
#include <queue>
#include <string>
#define _SCL_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#pragma warning(disable:4996)
using namespace std;
//前面三个字节的转移指令、末尾448字节的引导代码和数据以及结束标志0xAA55在以下结构体中不体现
struct section
{
	unsigned char ram512[512];
	section()
	{
		for (int i = 0; i < 512; i++)
			ram512[i] = '\0';
	}
};

struct fat12header
{
	char BS_OEMName[8];//厂商名
	unsigned short BPB_BytesPetSec;//每扇区字节数
	unsigned char BPB_SecPerClus;//每簇扇区数
	unsigned short BPB_RsvdSecCnt;//Boot记录占用多少扇区
	unsigned char BPB_NumFATs;//共有多少FAT表
	unsigned short BPB_RootEntCnt;//根目录文件数最大值
	unsigned short BPB_TotSec16;//扇区总数
	unsigned char BPB_Media;//介质描述符
	unsigned short BPB_FATSz16;//每FAT扇区数
	unsigned short BPB_SecPerTrk;//每磁道扇区数
	unsigned short BPB_NumHeads;//磁头数
	unsigned int BPB_HiddSec;//隐藏扇区数
	unsigned int BPB_TotSec32;//值记录扇区数
	unsigned char BS_DrvNum;//中断13的驱动器号
	unsigned char BS_Reserved1;//未使用
	unsigned char BS_BootSig;//扩展引导记录
	unsigned int BS_VolID;//卷序列号
	char BS_VolLab[11];//卷标
	char BS_FileSysType[8];//文件系统类型


}Header;
//根目录项的结构如下，当从ramFDD144大数组中提取信息时，用强制类型转换
//根目录区可以定义成16个根目录项的数组
struct RootEntry
{
	unsigned char DIR_Name[11];//文件名
	unsigned char DIR_Attr;//文件属性
	unsigned char Reserve[10];//保留位
	unsigned short DIR_WrtTime;//最后一次写入时间：秒
	unsigned short DIR_WrtDate;//最后一次写入日期：天
	unsigned short DIR_FstClus;//文件开始的簇号
	unsigned int DIR_FileSize;//文件大小
	RootEntry()
	{
		for (int i = 0; i < 11; i++)
			DIR_Name[i] = '\0';
		DIR_Attr = 0x01;
	}
}*root;
//FAT12表项！占9个扇区，每个表项占12bits,FAT表可看成所有表项的集合
struct FATTable
{
	unsigned char word[4608];//难点！12位怎么截取？怎么存储？
}tab;
struct DataPart
{
	section part[2880 - 1 - 18 - 14];
}dp;
struct ACTIVE_FILE{
		RootEntry dir;
		string path;
		int share_counter;
		ACTIVE_FILE()
		{
			path = "";
			share_counter = 0;
		}
} FILE_active_list[100];
struct OPEN_FILE {
	int rw;
	ACTIVE_FILE *af;
	OPEN_FILE()
	{
		rw = 0;
		af = NULL;
	}
}FILE_open_list[10];
	
struct Sec_use
{
	queue<int>number;//可用的数据块号是相对于整个文件系统而言的号
}DP_USE;
