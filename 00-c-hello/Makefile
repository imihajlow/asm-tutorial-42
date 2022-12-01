hello: hello.o
	gcc -o $@ $^

hello-static: hello.o
	gcc -o $@ -static $^

clean:
	rm -f *.o hello hello-static
