#include <gruby.h>
#include <readline/readline.h>


int cmdfunc0(int count, int key) { rb_yield(Qnil); return 0; }
int cmdfunc1(int count, int key) { rb_yield(Qnil); return 0; }
int cmdfunc2(int count, int key) { rb_yield(Qnil); return 0; }


rl_command_func_t *cmdfuncs[3];
int cmdfuncs_index=0;

VALUE readline_bind(self, key)
	VALUE self, key;
{
	rl_bind_key(FIX2CHR(key), cmdfuncs[cmdfuncs_index++] );

	return Qnil;
}

int cmd_guten(int count, int key){
	printf("guten");
	return 0;
}

int startup_hook()
{
	rl_bind_key(';', (rl_command_func_t *)cmd_guten);
	//rl_parse_and_bind("\"a\": custom");

	return 0;
}

void Init_readline()
{
	VALUE mReadline = rb_define_module("Readline");
	cmdfuncs[0] = cmdfunc0;
	cmdfuncs[1] = cmdfunc1;
	cmdfuncs[2] = cmdfunc2;

	rb_define_module_function(mReadline, "bind", readline_bind, 1);

	rl_add_defun("custom", (rl_command_func_t *)cmd_guten, -1);
	//rl_parse_and_bind("\"a\":\"guten\"");

	rl_startup_hook = startup_hook;

}
