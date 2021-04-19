#include <iostream>
#include <fstream>
#include <string>
#include "function.h"
using namespace std;
ifstream in;
ofstream out;

int main()
{
	section *ramFDD144;
	ramFDD144 = new section[2880];//初始默认全为0；
	in.open("dossys.img",ios::in|ios::binary);
	int i = 0;
	int j = 0;
	while (j<2880)//按照一个字节大小读入，读入的数字由于是按照字符类型存储的，因此会转换成相应的字符！
	{
		if (i >= 512)
		{
			j++;
			i %= 512;
		}
		int c;
		c = in.get();
		ramFDD144[j].ram512[i] = (unsigned char)c;
		/*if(i==263)
		    in >> ramFDD144[j].ram512[i];
		else
			in >> ramFDD144[j].ram512[i];*/
		/*if(j==0)
		cout << ramFDD144[j].ram512[i]-'\0'<<endl;//用此转换即可以将char字符转换成对应的一个字节大小的十进制数。*/
		i++;
	}
	in.close();
	Header = get_Head(ramFDD144);
	root = Root(ramFDD144);
	int k = 0;
	for (int i = 1; i <= 9; i++)
	{
		for (int j = 0; j < 512; j++,k++)
		{
			tab.word[k] = ramFDD144[i].ram512[j];
		}
	}
	for (int i = 33; i < 2880; i++)
	{
		dp.part[i - 33] = ramFDD144[i];
	}
	for (int i = 2846; i > 2800; i--)
	{
		DP_USE.number.push(i+33);
	}
	//cout << "\t\t\t\tWelcome!\t\t\t\t" << endl;
	cout << "\t\t\t\tMenu\t\t\t\t" << endl;
	cout << "dir-List RootEntry" << endl;
	cout << "check-Check the FAT12 format" << endl;
	cout << "ls-List the directory tree" << endl;
	cout << "del-Delete a specified file" << endl;
	cout << "type-Show the contents of a specified file" << endl;
	cout << "cd-Open the folder" << endl;//打开文件夹，此时路径显示变化就行！接着用路径操作就行！
	cout << "cls-Close a specified file" << endl;
	cout << "make-Create a file" << endl;
	cout << "dis-Display imformation of header" << endl;
	cout << "makedir-Create a subditectory" << endl;
	cout << "Q-Quit" << endl;
	string cmd;
	string p = "A:/";
	cout <<endl<<endl<< "Please input the command" << endl;
	cout << p;
	cin >> cmd;
	while (cmd != "Q")
	{
		if (cmd == "dir")//已测试
		{
			//cout <<endl;
			string path = p.substr(2, p.size() - 2);
			List_subEntry(path, root, tab, dp);
		}
		else if (cmd == "check")//已测试
		{
			//cout << endl;
			for (int l = 0; l < p.size(); l++)
			{
				if (p[l] != ' ')
					cout << p[l];
			}
			//cout << p;
			if (Header_Format(ramFDD144))
				cout << "It is a FAT12 format!" << endl;
			else
				cout << "It is not a FAT12 format" << endl;
		}
		else if (cmd == "ls")//已测试
		{
			//cout << endl;
			//cout <<p;
			for (int l = 0; l < p.size(); l++)
			{
				if (p[l] != ' ')
					cout << p[l];
			}
			List_Tree(root,tab,dp);
		}
		else if (cmd =="type")//已测试！
		{
			//cout << endl;
			//cout << p;
			/*for (int l = 0; l < p.size(); l++)
			{
				if (p[l] != ' ')
					cout << p[l];
			}*/
			cin.get();
			string filename;
			getline(cin, filename);
			while (filename.size() < 11)
			{
				filename += " ";
			}
			string path = p.substr(2, p.size() - 2);
			display(path + filename + "/", root, tab, dp);
			cout << endl;
		}
		else if (cmd == "del")//已测试
		{
			//cout << endl;
			//cout << p;
			/*for (int l = 0; l < p.size(); l++)
			{
				if (p[l] != ' ')
					cout << p[l];
			}*/
			cin.get();
			string filename;
			getline(cin, filename);
			while (filename.size() < 11)
			{
				filename += " ";
			}
			string path = p.substr(2, p.size() - 2);
			del_subEntry(path, filename,root, tab, dp);
		}
		else if (cmd == "cd")//已测试！
		{
			//cout << endl;
			cin.get();
			string folder;
			getline(cin, folder);
			if (folder == "..")
			{
				int index = 0;
				p[p.size() - 1] = ' ';
				for (int m = p.size() - 2; m >= 0; m--)
				{
					if (p[m] == '/')
					{
						index = m;
						break;
					}
				}
				p = p.substr(0, index + 1);
			}
			else
			{
				while (folder.size() < 11)
				{
					folder += " ";
				}
				string test = p + folder + '/';
				test = test.substr(2, test.size() - 2);
				if (OpenFile(test, 0, root, tab, dp) != NULL)
				{
					p += folder;
					p += "/";
					//cout << p;
				}
			}
		}
		else if (cmd == "dis")//已测试
		{
			Dis_head(Header);
		}
		else if (cmd == "help")//已测试
		{
		cout << "\t\t\t\tMenu\t\t\t\t" << endl;
		cout << "dir-List RootEntry" << endl;
		cout << "check-Check the FAT12 format" << endl;
		cout << "ls-List the directory tree" << endl;
		cout << "del-Delete a specified file" << endl;
		cout << "type-Show the contents of a specified file" << endl;
		cout << "cd-Open the folder" << endl;//打开文件夹，此时路径显示变化就行！接着用路径操作就行！
		cout << "cls-Close a specified file" << endl;
		cout << "make-Create a file" << endl;
		cout << "dis-Display imformation of header" << endl;
		cout << "makedir-Create a subditectory" << endl;
		cout << "help-check the command list" << endl;
		cout << "Q-Quit" << endl;
        }
		//cout << p;
		else if (cmd == "make")//已测试！
		{
		    cin.get();
		    string filename;
		    getline(cin, filename);
		    while (filename.size() < 11)
		    {
			    filename += " ";
		    }
		    string path = p.substr(2, p.size() - 2);
			//cin.get();
			string text;
			getline(cin, text);
			make_subfile(path, filename, root, text);
        }
		else if (cmd == "makedir")
		{
		    cin.get();
		    string filename;
		    getline(cin, filename);
		    while (filename.size() < 11)
		    {
			     filename += " ";
		    }
		    string path = p.substr(2, p.size() - 2);
			make_subdir(path, filename, root);
		    //cin.get();
        }
		else if (cmd == "cls")
		{
		    cin.get();
		    string filename;
		    getline(cin, filename);
		    while (filename.size() < 11)
		    {
			    filename += " ";
		    }
		    string path = p.substr(2, p.size() - 2);
		    CloseFile(path,root,tab,dp);
        }
		for (int l = 0; l < p.size(); l++)
		{
			if (p[l] != ' ')
				cout << p[l];
		}
		cin >> cmd;
	}
	WB(ramFDD144, root, tab, dp);
	return 0;
}