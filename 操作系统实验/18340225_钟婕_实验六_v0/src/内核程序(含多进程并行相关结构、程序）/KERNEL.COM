3���&�� �&�� �Ȏ؎��м���� �  ��! �	��U��VW�v�~
������_^]� PSQR�� � � ��O�� ��� �  �ZY[Xô �.���PU3���&�� �&�� ��Ȏ�� ���� ��N
� ��0�� �G �/�Ȏ؎���]]X�PU3���&�� �&�� ��Ȏ�� ���� ��N
� ��0�� �G �/�Ȏ؎����U��F�� ���]��"�PU��F��� ��� ��N��t� �]Xð� �]X�P�4�C��t�@���@X�P���3���&�  m&�" X��X�  .�>4 u�� .�k.�>k�u.�4  .�2  .�k  .�:  �+�PSQRTUVW���Ȏ��������_^]\ZY[X�Ȏ����| �Ȏ����[��>�V >�f>�~  uQ�7>�v>�v>�v>�v>�v>�v>�v>�v
>�v>�v>�v>�v>�v>�vXYZ[]^_��P� � �Xσ���	 P� � �X�PSQRU�Ȏ�&��t�k�&��&�>�t&�>�t&�>�t &�>�t$&��&���&�&��&����&��&����&��&������ ���&��&��]ZY[X�|/-\PSQRU�Ȏ��� &�;� ��#�5� �&�;�&:;t�
�&�;��PQR��� �@B�ZYX]ZY[X�INT22H�2�" ��H� �U��VW�~�v�D ��<�|�|�|�|�F�D�F���D�D  �D  �D  �D  �D
  �D  �D  �D �*�D _^]�U��FP�2�" ���X��`�FP�2�" ���X��Z�FP�2�" ���X��^�FP�2�" ���X��\�F
P�2�" ���X��P�FP�2�" ���X��N�FP�2�" ���X��L�FP�2�" ���X��J�FP�2�" ���X��H�FP�2�" ���X��R�FP�2�" ���X��T�FP�2�" ���X��X�FP�2�" ���X��V�FP�2�" ���X��b�F P�2�" ���X��d�F"P�2�" ���X��f]á,P�2�" ���X��h�2�2;4~�2 �2�" ��؋�h;*t�.P�2�" ���X��há2�" ��؋�h;*u�.P�2�" ���X��h�U��V3����G�>�u+�t"���P��Y�  P��YN���P�~�Y������������P�i�Y���^� F����>�u��^�  ^]�U��V3���^� �P�:�YF�^�8 u�^]�U��VW3�3���^� �^:t3��'FG�^�8 t�^�9 uދ^�8 u�^�9 u� � _^]ø>P��Y�aP��Y�yP��Y��P�|�Y��P�t�Y� P�l�Y� P�d�Y�BP�\�Y�]P�T�Y�VW3�3�3��3��FNF��'|�G��'|�_^�U���VW�~� �F�  �F�  �(�ފ����F��F��<�6<�6:�Z�YY�: �F�F�ހ9 t�ހ90|�ހ99~ËF��4_^��]øuP���Y��P��Y��P��Y��P��Y�%P��Y�WP��Y��P��Y��P��Y��P��Y�U��V�v�<pu��V�A�Y������� � PV��YY�t	������ �$PV�h�YY�t����)P��Y������� �,PV�F�YY�t���2P��Y��P��Y��P�t Y�m �TPV��YY�t�8  �W�WPV��YY�t�A��D�\PV���YY�t�[��1�`PV���YY�t� ��cPV���YY�t�6  ��hP��Y^]�U���
VW3�3��*�^�8 u�C� �F�P���Y� P�� Y3��	�^� �C�GF�^�8 t�>6 t�>8 u��^�8 u�C� �F�P��Y� P� Y_^��]ø�P��Y��P��Y��P��Y��P��Y��P���Y��P���Y�P���Y�P���Y�#P���Y�4P���Y�EP���Y�WP���Y�lP��Y�P��Y��P��Y��P��Y��P��Y�U��~ u� P� P�HP���� P�  P�jP���� P� 0P��P����� P� @P��P����� P� PP��P�����]ø�P�3�Y�P�+�Y�QP�#�Y��P��Y��P��Y�P��Y�_P��Y��P���Y��P���Y�����3�P�K�Y�+P�X�Y�k��2��e���� � P�-�Y�.P��Y��P�U�Y��P�*�Y�>6 u��6��3P��Y�+��6P��Y�D��                
help-display the command list.
 cls-clear the window.
 p1234-run the four UP in order. You can change the order od numbers.
 test-run the libs program.
 dir-display the table of UPInfo.
 ls-dispaly the tree of files.
 batch-run a series of commands.
 qb-exit the DIY running.
 quit-exit the system.
 
 Total File Number: 7
       FileName      ||    Addr      || FileSize
   UP1:Square        || 2400H~2600H  || 407Bytes
   UP2:Single stone  || 2600H~2800H  || 438Bytes
   UP3:Double stone  || 2800H~2A00H  || 508Bytes
   UP4:Sand Clock    || 2A00H~2C00H  || 326Bytes
   Test              || 3200H~3A00H  || 1686Bytes
   Loading           || 2E00H~3000H  || 512Bytes
   Close             || 3000H~3200H  || 392Bytes
 dir test p8 batch Please separate cmds by Spaces.
 qb help cls ls quit 
Please input the correct instructions.
 
|-boot.bin
 |--kernal.com
 |--------rukou.asm
 |--------PCB.h
 |--------kernal.c
 |--------bacis.asm
 |------UP1.com
 |------UP2.com
 |------UP3.com
 |------UP4.com
 |------test.com
 |--------enter.asm
 |--------Stuct.h
 |--------test.c
 |--------libs.asm
 |------Loading.com
 |------Close.com
           .  .   .                 ,             .__. __.      
           |  | _ | _. _ ._ _  _   -+-_  ._ _    .|  |(__       
           |/|(/,|(_.(_)[ | )(/,   |(_)  [ | )_|  |__|.__)      
                                               ._|                
 *****************************************************************
 |           Author:Jie Zhong  Student Number:18340225           |
 |             Input help to view the command list.              |
 |                     Have a good time!                         |
 *****************************************************************
 p6 
>> p7 
Quit! Bye-bye! 