#include <iostream>
#include <queue>
#include <string>
#define _SCL_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#pragma warning(disable:4996)
using namespace std;
//ǰ�������ֽڵ�ת��ָ�ĩβ448�ֽڵ���������������Լ�������־0xAA55�����½ṹ���в�����
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
	char BS_OEMName[8];//������
	unsigned short BPB_BytesPetSec;//ÿ�����ֽ���
	unsigned char BPB_SecPerClus;//ÿ��������
	unsigned short BPB_RsvdSecCnt;//Boot��¼ռ�ö�������
	unsigned char BPB_NumFATs;//���ж���FAT��
	unsigned short BPB_RootEntCnt;//��Ŀ¼�ļ������ֵ
	unsigned short BPB_TotSec16;//��������
	unsigned char BPB_Media;//����������
	unsigned short BPB_FATSz16;//ÿFAT������
	unsigned short BPB_SecPerTrk;//ÿ�ŵ�������
	unsigned short BPB_NumHeads;//��ͷ��
	unsigned int BPB_HiddSec;//����������
	unsigned int BPB_TotSec32;//ֵ��¼������
	unsigned char BS_DrvNum;//�ж�13����������
	unsigned char BS_Reserved1;//δʹ��
	unsigned char BS_BootSig;//��չ������¼
	unsigned int BS_VolID;//�����к�
	char BS_VolLab[11];//���
	char BS_FileSysType[8];//�ļ�ϵͳ����


}Header;
//��Ŀ¼��Ľṹ���£�����ramFDD144����������ȡ��Ϣʱ����ǿ������ת��
//��Ŀ¼�����Զ����16����Ŀ¼�������
struct RootEntry
{
	unsigned char DIR_Name[11];//�ļ���
	unsigned char DIR_Attr;//�ļ�����
	unsigned char Reserve[10];//����λ
	unsigned short DIR_WrtTime;//���һ��д��ʱ�䣺��
	unsigned short DIR_WrtDate;//���һ��д�����ڣ���
	unsigned short DIR_FstClus;//�ļ���ʼ�Ĵغ�
	unsigned int DIR_FileSize;//�ļ���С
	RootEntry()
	{
		for (int i = 0; i < 11; i++)
			DIR_Name[i] = '\0';
		DIR_Attr = 0x01;
	}
}*root;
//FAT12���ռ9��������ÿ������ռ12bits,FAT��ɿ������б���ļ���
struct FATTable
{
	unsigned char word[4608];//�ѵ㣡12λ��ô��ȡ����ô�洢��
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
	queue<int>number;//���õ����ݿ��������������ļ�ϵͳ���Եĺ�
}DP_USE;
