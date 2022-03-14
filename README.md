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