# Simple Assembly Crypter based on xor written handly by an idle guy ππ
#### Description
Just as a hobby.

\* This is not really dangerous cause it is just a simple xor encryption(Just don't use it in root(/) folderπ)
#### Set encryption key
Just enter key bytes in line 4 (which now is 3,11,75).

\* You could use strings too ('k','e','y')
#### How to run?
Just assemble the program and link it to use it.
How?
>$ nasm -felf32  main.asm; ld -s -melf_i386 -o main main.o

### BTW This is 32x linux code π
#### Known issue
* If there is a folder it will stop as getting to the folder.
#### TODO
- [ ] First solve known issues ππ
- [ ] Write encrypting folder files as a function to add subfolders encryption
- [ ] Add subfolder encryption (and parentfolder if have permission)
##### Just wrote it for learning hope you guys don't use it for other purpose too. ππ(like its a big deal π)
