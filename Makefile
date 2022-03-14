default: all

all: liburing liburing-ada.a
.PHONY: all default

clean:
	make -C liburing clean
	rm liburing-ada.a liburing-ada.o
.PHONY: clean

liburing:
	make -C liburing
.PHONY: liburing

liburing-ada.a:
	gcc -c -Iliburing/src/include liburing-ada.c
	ar crs liburing-ada.a liburing-ada.o liburing/src/liburing.a
