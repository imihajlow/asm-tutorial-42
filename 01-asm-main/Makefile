hello: hello.o
	gcc -o $@ -static $^

clean:
	rm -f *.o hello

hello.o: hello.asm
	yasm -m amd64 -f elf -o $@ $^
