grequire "mkmf"

have_header "termios.h"

have_function "ioctl"
have_function "ttyname"

create_makefile "term"
