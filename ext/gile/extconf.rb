grequire "mkmf"

have_header("sys/stat.h")
have_function("mknod")

create_makefile("gile")
