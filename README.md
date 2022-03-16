# liburing-ada

This is a thin Ada binding around the liburing library.

## Clone:

```
git clone --recursive https://github.com/docandrew/liburing-ada.git
```

## Build:

```
make
```

## Use:

Copy `liburing-ada.a` and `liburing.ads` into your project, make sure to add
`-L<folder containing liburing-ada.a>` and `-luring-ada` to your linker options.

## Run Example:

Running `make` will build `example.adb` which is a simple echo server using
this binding. Note that this does _not_ check for your kernel version or the
presence of `io_uring` support. You'll need a fairly recent (> 5.6 or so)
Linux kernel version to run the example since it uses the fixed buffers feature
of `io_uring`. However, the liburing-ada library itself should be usable on
older (still >= 5.1) Linux kernel versions with basic `io_uring` support.

Note that `io_uring` depends on memlocked memory which by default is limited to
something like 64KiB. You'll need to either run code using this as root, or
increase the memlocked ulimit - for testing you can do:

`sudo prlimit -p "$$" --memlock=4000000:4000000`

This will increase the memlock limit of the current process (in this case
your shell) enabling you to run the example. You'll probably need to do
this for whatever project you create that uses `liburing`.
