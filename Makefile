default: all

all: liburing/src/liburing.a liburing-ada.a example
.PHONY: all default

clean:
	make -C liburing clean
	rm liburing-ada.a liburing-ada.o example *.ali *.o
.PHONY: clean

liburing/src/liburing.a:
	make -C liburing
.PHONY: liburing

liburing-ada.a: liburing/src/liburing.a liburing-ada.c
	gcc -c -Iliburing/src/include liburing-ada.c
	cp liburing/src/liburing.a liburing-ada.a
	ar rsv liburing-ada.a liburing-ada.o

example: liburing-ada.a example.adb
	gnatmake example.adb -L. -largs -luring-ada
