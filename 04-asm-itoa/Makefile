itoa: itoa.o
	ld -o $@  $^

clean:
	rm -f *.o itoa

itoa.o: itoa.asm
	yasm -m amd64 -f elf -o $@ $^
