#!/usr/bin/env ruby

grequire "test"
rrequire "gile.so"

class Test_Gile < Test
		def test_mknod 
tmpfile = Gile.mktmpfile
	Gile.mknod(tmpfile, :chardev, "/dev/console", mode:0777)
	assert_equal :chardev, Gile.type(tmpfile)
	assert_equal 0100777, Gile.lstat(tmpfile).mode
Gile.rm(tmpfile)

tmpfile = Gile.mktmpfile
	Gile.mknod(tmpfile, :fifo)
	assert_equal :fifo, Gile.type(tmpfile)
Gile.rm(tmpfile)

tmpfile = Gile.mktmpfile
	assert_raise(Gile::Eexist){
		Gile.touch(tmpfile)
		Gile.mknod(tmpfile, :fifo)
	}
Gile.rm(tmpfile)
		end if win32?
end
