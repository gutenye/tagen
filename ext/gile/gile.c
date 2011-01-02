#include <sys/stat.h>
#include <gruby.h>

VALUE eError, eExist, eNoEnt, ePerm, eNotSupport, eAccess, eNotDir, eIsDir, \
			eNotSymlink, eLinkSelf, eDangling;

// type_@ ?c 
// mode_@ 0644
// dev_@ 0
VALUE gile_mknod(self, path_, type_, mode_, dev_) 
	VALUE self, path_, type_, mode_, dev_;
{
#ifdef HAVE_MKNOD

	// handle args
	char *path = rb_str_newv(path_);
	int type = FIX2CHR(type_);
	int mode = FIX2INT(mode_);
	int dev = FIX2INT(dev_);

	// begin
	switch (type) {
		case 'f': mode |= S_IFREG; break;
		case 'c': mode |= S_IFCHR; break;
#ifdef S_IFBLK
	  case 'b': mode |= S_IFBLK; break;
#endif
#ifdef S_IFIFO
	  case 'p': mode |= S_IFIFO; break;
#endif
	}

	if (mknod(path, mode, dev)) 
		rb_sys_fail("mknod");

	return INT2FIX(0);
#else
		rb_notimplement();
#endif
}

void Init_gile() 
{
	// class Gile
	VALUE cGile = rb_define_class("Gile", rb_cFile);

	// Error < Exception
	eError     	=  rb_define_class_under(cGile, "Error"     , rb_eException);
	eExist    	=  rb_define_class_under(cGile, "EExist"    , eError);
	eNoEnt   		=  rb_define_class_under(cGile, "ENoEnt"   , eError);
	ePerm     	=  rb_define_class_under(cGile, "EPerm"     , eError);
	eNotSupport =  rb_define_class_under(cGile, "ENotSupport" , eError);
	eAccess   	=  rb_define_class_under(cGile, "EAccess"   , eError);
	eNotDir     =  rb_define_class_under(cGile, "ENotDir"     , eError);
	eIsDir    	=  rb_define_class_under(cGile, "EIsDir"    , eError);
	eNotSymlink =  rb_define_class_under(cGile, "ENotSymlink" , eError);
	eLinkSelf 	=  rb_define_class_under(cGile, "ELinkSelf" , eError);
	eDangling 	=  rb_define_class_under(cGile, "EDangling" , eError);

	// method
	rb_define_singleton_method(cGile, "mknod", gile_mknod, 4);

}


