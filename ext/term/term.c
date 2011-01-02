//{{{1
#include <gruby.h>
#include <ruby/io.h>
#include <sys/ioctl.h> 
#include <stdio.h>
#include <unistd.h> // ttyname

#include <error.h>
#include <errno.h>

#include <termios.h>
#include <sys/ttychars.h>

VALUE getfd(VALUE);

VALUE sTerm;
//}}}1

/* 
VALUE getfd(VALUE obj) //{{{1
{
	VALUE fd;
	rb_io_t *fptr;
	FILE *f;

	switch (TYPE(obj)){
		case T_STRING:
			f = fopen(StringValuePtr(obj), "r");
			if (!f) rb_raise(rb_eIOError, "can't open file");
			fd = INT2FIX(fileno(f));
			break;
		case T_FILE:
			GetOpenFile(obj, fptr);
			fd = INT2FIX( fptr->fd );
			break;
		case T_FIXNUM:
			break;
		default:
			rb_raise(rb_eTypeError, "wrong type");
	}

	return fd;
} 
//}}}1
*/
/* 
VALUE term_initialize(self, std_in, std_out) //{{{1
	VALUE self, std_in, std_out;
{
	rb_ivar_set(self, rb_id_newc("@fd"), getfd(std_out));
	rb_ivar_set(self, rb_id_newc("@stdin"), std_in);
	rb_ivar_set(self, rb_id_newc("@stdout"), std_out);

	return self;
}
//}}}1
*/

// __getattr __setattr //{{{1
VALUE term___getattr(self)
	VALUE self;
{
	struct termios attr;
	int i;

	int fd= FIX2INT(rb_ivar_get(self, rb_id_newc("@fd")));
	if (tcgetattr(fd, &attr))
		error(-1, errno, "guten");

	// convert attr.c_cc to cc_ary(:Ruby Array).
	VALUE cc_ary = rb_ary_new2(NCCS);
	for (i=0; i<NCCS; i++)
		rb_ary_store(cc_ary, i, CHR2FIX(attr.c_cc[i]));
		
	return rb_struct_new(sTerm, 
			INT2FIX(attr.c_iflag), 
			INT2FIX(attr.c_oflag), 
			INT2FIX(attr.c_cflag), 
			INT2FIX(attr.c_lflag), 
			cc_ary
			);
}

VALUE term___setattr(VALUE self, VALUE when, VALUE attrobj)
{
	struct termios attr;
	int i;

	int fd= FIX2INT(rb_ivar_get(self, rb_id_newc("@fd")));

	// set c_iflag oflag cflag lflag
	attr.c_iflag = FIX2INT(rb_struct_aref(attrobj, rb_str_new2("iflag")));
	attr.c_oflag = FIX2INT(rb_struct_aref(attrobj, rb_str_new2("oflag")));
	attr.c_cflag = FIX2INT(rb_struct_aref(attrobj, rb_str_new2("cflag")));
	attr.c_lflag = FIX2INT(rb_struct_aref(attrobj, rb_str_new2("lflag")));

	// set c_cc
	VALUE cc_ary = rb_struct_aref(attrobj, rb_str_new2("cc"));
	for (i=0; i<NCCS; i++)
		attr.c_cc[i] = FIX2CHR(rb_ary_entry(cc_ary, i));

	// convert when(:Symbol) to int
	int when_c=TCSANOW;
	ID when_id = rb_to_id(when);

	if (when_id == rb_intern("now"))
		when_c = TCSANOW; 
	else if (when_id == rb_intern("drain"))
		when_c = TCSADRAIN;
	else if (when_id == rb_intern("flush"))
		when_c = TCSAFLUSH;
	

	// tcsetattr
	tcsetattr(fd, when_c, &attr);
	
	return Qnil;
}
//}}}1
// wh setwh //{{{1
VALUE term_wh(self)
	VALUE self;
{
#ifdef TIOCGWINSZ
	struct winsize wsize;
	int fd = FIX2INT(rb_ivar_get(self, rb_id_newc("@fd")));
	
	if (ioctl(fd, TIOCGWINSZ, &wsize))
		error(-1, errno, "guten");

	return rb_ary_new3(2, INT2FIX(wsize.ws_col), INT2FIX(wsize.ws_row));
#else
	rb_notimplement();
#endif
}

VALUE term_setwh(self, width, height)
	VALUE self; int width,height;
{
#ifdef TIOCSWINSZ
	int fd = FIX2INT(rb_ivar_get(self, rb_id_newc("@fd")));
	struct winsize wsize;
	wsize.ws_col = width;
	wsize.ws_row = height;

	if (ioctl(fd, TIOCSWINSZ, &wsize))
		error(-1, errno, "guten");

	return Qnil;
#else
	rb_notimplement();
#endif
}



//}}}1
VALUE term_dev_path(VALUE self)  //{{{1
{
	int fd = FIX2INT(rb_ivar_get(self, rb_id_newc("@fd")));
	return rb_str_new2(ttyname(fd));
}

//}}}1

void Init_term() //{{{1
{

	sTerm = rb_struct_define("Term", "iflag", "oflag", "cflag", "lflag", "cc", NULL);

	VALUE cTerm = rb_define_class("Term", rb_cObject);

	rb_define_method(cTerm, "wh", 				term_wh, 0);
	rb_define_method(cTerm, "setwh", 				term_setwh, 2);
	rb_define_method(cTerm, "dev_path", 	term_dev_path, 0);
	rb_define_method(cTerm, "__getattr", 	term___getattr, 0);
	rb_define_method(cTerm,  "__setattr", term___setattr, 2);

	/* 
 	 * constants
	 */
	rb_define_const(cTerm, "NCCS", INT2FIX(NCCS));
#ifdef __USE_MISC
	rb_define_const(cTerm, "USE_MISC__", INT2FIX(__USE_MISC));
#endif
#ifdef __USE_XOPEN
	rb_define_const(cTerm, "USE_XOPEN__", INT2FIX(__USE_XOPEN));
#endif
	// c_cc constants. c_iflag c_cflag c_lflag //{{{2 
	// rfrom: termios.h
	// c_cc characters
	rb_define_const(cTerm, "VINTR", INT2FIX(VINTR));
	rb_define_const(cTerm, "VQUIT", INT2FIX(VQUIT));
	rb_define_const(cTerm, "VERASE", INT2FIX(VERASE));
	rb_define_const(cTerm, "VKILL", INT2FIX(VKILL));
	rb_define_const(cTerm, "VEOF", INT2FIX(VEOF));
	rb_define_const(cTerm, "VTIME", INT2FIX(VTIME));
	rb_define_const(cTerm, "VMIN", INT2FIX(VMIN));
	rb_define_const(cTerm, "VSWTC", INT2FIX(VSWTC));
	rb_define_const(cTerm, "VSTART", INT2FIX(VSTART));
	rb_define_const(cTerm, "VSTOP", INT2FIX(VSTOP));
	rb_define_const(cTerm, "VSUSP", INT2FIX(VSUSP));
	rb_define_const(cTerm, "VEOL", INT2FIX(VEOL));
	rb_define_const(cTerm, "VREPRINT", INT2FIX(VREPRINT));
	rb_define_const(cTerm, "VDISCARD", INT2FIX(VDISCARD));
	rb_define_const(cTerm, "VWERASE", INT2FIX(VWERASE));
	rb_define_const(cTerm, "VLNEXT", INT2FIX(VLNEXT));
	rb_define_const(cTerm, "VEOL2", INT2FIX(VEOL2));

	// c_iflag bits
	rb_define_const(cTerm, "IGNBRK", INT2FIX(IGNBRK));
	rb_define_const(cTerm, "BRKINT", INT2FIX(BRKINT));
	rb_define_const(cTerm, "IGNPAR", INT2FIX(IGNPAR));
	rb_define_const(cTerm, "PARMRK", INT2FIX(PARMRK));
	rb_define_const(cTerm, "INPCK", INT2FIX(INPCK));
	rb_define_const(cTerm, "ISTRIP", INT2FIX(ISTRIP));
	rb_define_const(cTerm, "INLCR", INT2FIX(INLCR));
	rb_define_const(cTerm, "IGNCR", INT2FIX(IGNCR));
	rb_define_const(cTerm, "ICRNL", INT2FIX(ICRNL));
	rb_define_const(cTerm, "IUCLC", INT2FIX(IUCLC));
	rb_define_const(cTerm, "IXON", INT2FIX(IXON));
	rb_define_const(cTerm, "IXANY", INT2FIX(IXANY));
	rb_define_const(cTerm, "IXOFF", INT2FIX(IXOFF));
	rb_define_const(cTerm, "IMAXBEL", INT2FIX(IMAXBEL));
	rb_define_const(cTerm, "IUTF8", INT2FIX(IUTF8));

	// c_oflag bits 
	rb_define_const(cTerm, "OPOST", INT2FIX(OPOST));
	rb_define_const(cTerm, "OLCUC", INT2FIX(OLCUC));
	rb_define_const(cTerm, "ONLCR", INT2FIX(ONLCR));
	rb_define_const(cTerm, "OCRNL", INT2FIX(OCRNL));
	rb_define_const(cTerm, "ONOCR", INT2FIX(ONOCR));
	rb_define_const(cTerm, "ONLRET", INT2FIX(ONLRET));
	rb_define_const(cTerm, "OFILL", INT2FIX(OFILL));
	rb_define_const(cTerm, "OFDEL", INT2FIX(OFDEL));
#if defined __USE_MISC || defined __USE_XOPEN
		rb_define_const(cTerm, "NLDLY", INT2FIX(NLDLY));
		rb_define_const(cTerm, "NL0", INT2FIX(NL0));
		rb_define_const(cTerm, "NL1", INT2FIX(NL1));
		rb_define_const(cTerm, "CRDLY", INT2FIX(CRDLY));
		rb_define_const(cTerm, "CR0", INT2FIX(CR0));
		rb_define_const(cTerm, "CR1", INT2FIX(CR1));
		rb_define_const(cTerm, "CR2", INT2FIX(CR2));
		rb_define_const(cTerm, "CR3", INT2FIX(CR3));
		rb_define_const(cTerm, "TABDLY", INT2FIX(TABDLY));
		rb_define_const(cTerm, "TAB0", INT2FIX(TAB0));
		rb_define_const(cTerm, "TAB1", INT2FIX(TAB1));
		rb_define_const(cTerm, "TAB2", INT2FIX(TAB2));
		rb_define_const(cTerm, "TAB3", INT2FIX(TAB3));
		rb_define_const(cTerm, "BSDLY", INT2FIX(BSDLY));
		rb_define_const(cTerm, "BS0", INT2FIX(BS0));
		rb_define_const(cTerm, "BS1", INT2FIX(BS1));
		rb_define_const(cTerm, "FFDLY", INT2FIX(FFDLY));
		rb_define_const(cTerm, "FF0", INT2FIX(FF0));
		rb_define_const(cTerm, "FF1", INT2FIX(FF1));
#endif

	rb_define_const(cTerm, "VTDLY", INT2FIX(VTDLY));
	rb_define_const(cTerm, "VT0", INT2FIX(VT0));
	rb_define_const(cTerm, "VT1", INT2FIX(VT1));

#ifdef __USE_MISC
		rb_define_const(cTerm, "XTABS", INT2FIX(XTABS));
#endif

	// c_cflag bit meaning 
#ifdef __USE_MISC
		rb_define_const(cTerm, "CBAUD", INT2FIX(CBAUD));
#endif
	rb_define_const(cTerm, "B0", INT2FIX(B0));
	rb_define_const(cTerm, "B50", INT2FIX(B50));
	rb_define_const(cTerm, "B75", INT2FIX(B75));
	rb_define_const(cTerm, "B110", INT2FIX(B110));
	rb_define_const(cTerm, "B134", INT2FIX(B134));
	rb_define_const(cTerm, "B150", INT2FIX(B150));
	rb_define_const(cTerm, "B200", INT2FIX(B200));
	rb_define_const(cTerm, "B300", INT2FIX(B300));
	rb_define_const(cTerm, "B600", INT2FIX(B600));
	rb_define_const(cTerm, "B1200", INT2FIX(B1200));
	rb_define_const(cTerm, "B1800", INT2FIX(B1800));
	rb_define_const(cTerm, "B2400", INT2FIX(B2400));
	rb_define_const(cTerm, "B4800", INT2FIX(B4800));
	rb_define_const(cTerm, "B9600", INT2FIX(B9600));
	rb_define_const(cTerm, "B19200", INT2FIX(B19200));
	rb_define_const(cTerm, "B38400", INT2FIX(B38400));
#ifdef __USE_MISC
		rb_define_const(cTerm, "EXTA", INT2FIX(B19200));
		rb_define_const(cTerm, "EXTB", INT2FIX(B38400));
#endif
	rb_define_const(cTerm, "CSIZE", INT2FIX(CSIZE));
	rb_define_const(cTerm, "CS5", INT2FIX(CS5));
	rb_define_const(cTerm, "CS6", INT2FIX(CS6));
	rb_define_const(cTerm, "CS7", INT2FIX(CS7));
	rb_define_const(cTerm, "CS8", INT2FIX(CS8));
	rb_define_const(cTerm, "CSTOPB", INT2FIX(CSTOPB));
	rb_define_const(cTerm, "CREAD", INT2FIX(CREAD));
	rb_define_const(cTerm, "PARENB", INT2FIX(PARENB));
	rb_define_const(cTerm, "PARODD", INT2FIX(PARODD));
	rb_define_const(cTerm, "HUPCL", INT2FIX(HUPCL));
	rb_define_const(cTerm, "CLOCAL", INT2FIX(CLOCAL));
#ifdef __USE_MISC
		rb_define_const(cTerm, "CBAUDEX", INT2FIX(CBAUDEX));
#endif
	rb_define_const(cTerm, "B57600", INT2FIX(B57600));
	rb_define_const(cTerm, "B115200", INT2FIX(B115200));
	rb_define_const(cTerm, "B230400", INT2FIX(B230400));
	rb_define_const(cTerm, "B460800", INT2FIX(B460800));
	rb_define_const(cTerm, "B500000", INT2FIX(B500000));
	rb_define_const(cTerm, "B576000", INT2FIX(B576000));
	rb_define_const(cTerm, "B921600", INT2FIX(B921600));
	rb_define_const(cTerm, "B1000000", INT2FIX(B1000000));
	rb_define_const(cTerm, "B1152000", INT2FIX(B1152000));
	rb_define_const(cTerm, "B1500000", INT2FIX(B1500000));
	rb_define_const(cTerm, "B2000000", INT2FIX(B2000000));
	rb_define_const(cTerm, "B2500000", INT2FIX(B2500000));
	rb_define_const(cTerm, "B3000000", INT2FIX(B3000000));
	rb_define_const(cTerm, "B3500000", INT2FIX(B3500000));
	rb_define_const(cTerm, "B4000000", INT2FIX(B4000000));
	rb_define_const(cTerm, "MAX_BAUD__", INT2FIX(B4000000));
#ifdef __USE_MISC
		rb_define_const(cTerm, "CIBAUD", INT2FIX(CIBAUD));
		rb_define_const(cTerm, "CMSPAR", INT2FIX(CMSPAR));
		rb_define_const(cTerm, "CRTSCTS", INT2FIX(CRTSCTS));
#endif

	// c_lflag bits  
	rb_define_const(cTerm, "ISIG", INT2FIX(ISIG));
	rb_define_const(cTerm, "ICANON", INT2FIX(ICANON));
#if defined __USE_MISC || defined __USE_XOPEN
		rb_define_const(cTerm, "XCASE", INT2FIX(XCASE));
#endif
	rb_define_const(cTerm, "ECHO", INT2FIX(ECHO));
	rb_define_const(cTerm, "ECHOE", INT2FIX(ECHOE));
	rb_define_const(cTerm, "ECHOK", INT2FIX(ECHOK));
	rb_define_const(cTerm, "ECHONL", INT2FIX(ECHONL));
	rb_define_const(cTerm, "NOFLSH", INT2FIX(NOFLSH));
	rb_define_const(cTerm, "TOSTOP", INT2FIX(TOSTOP));
#ifdef __USE_MISC
		rb_define_const(cTerm, "ECHOCTL", INT2FIX(ECHOCTL));
		rb_define_const(cTerm, "ECHOPRT", INT2FIX(ECHOPRT));
		rb_define_const(cTerm, "ECHOKE", INT2FIX(ECHOKE));
		rb_define_const(cTerm, "FLUSHO", INT2FIX(FLUSHO));
		rb_define_const(cTerm, "PENDIN", INT2FIX(PENDIN));
#endif
	rb_define_const(cTerm, "IEXTEN", INT2FIX(IEXTEN));
//}}}2
	// ttychars constants.  //{{{2
	// rfrom: sys/ttychars.h  
	rb_define_const(cTerm, "CEOF", INT2FIX(CEOF));
	rb_define_const(cTerm, "CEOL", INT2FIX(CEOL));
	rb_define_const(cTerm, "CERASE", INT2FIX(CERASE));
	rb_define_const(cTerm, "CINTR", INT2FIX(CINTR));
	rb_define_const(cTerm, "CSTATUS", INT2FIX(CSTATUS));
	rb_define_const(cTerm, "CKILL", INT2FIX(CKILL));
	rb_define_const(cTerm, "CMIN", INT2FIX(CMIN));
	rb_define_const(cTerm, "CQUIT", INT2FIX(CQUIT));
	rb_define_const(cTerm, "CSUSP", INT2FIX(CSUSP));
	rb_define_const(cTerm, "CTIME", INT2FIX(CTIME));
	rb_define_const(cTerm, "CDSUSP", INT2FIX(CDSUSP));
	rb_define_const(cTerm, "CSTART", INT2FIX(CSTART));
	rb_define_const(cTerm, "CSTOP", INT2FIX(CSTOP));
	rb_define_const(cTerm, "CLNEXT", INT2FIX(CLNEXT));
	rb_define_const(cTerm, "CDISCARD", INT2FIX(CDISCARD));
	rb_define_const(cTerm, "CWERASE", INT2FIX(CWERASE));
	rb_define_const(cTerm, "CREPRINT", INT2FIX(CREPRINT));
	rb_define_const(cTerm, "CEOT", INT2FIX(CEOT));
/* compat */
	rb_define_const(cTerm, "CBRK", INT2FIX(CBRK));
	rb_define_const(cTerm, "CRPRNT", INT2FIX(CRPRNT));
	rb_define_const(cTerm, "CFLUSH", INT2FIX(CFLUSH));
//}}}2

}
//}}}1
