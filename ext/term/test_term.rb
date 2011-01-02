#!/usr/bin/env ruby
rrequire "libterm.so"
grequire "test"

class LibTerm
		def initialize 
@fd = $stdin.fd
		end
end

class Test_LibTerm < Test
		def test_dev_path
assert_equal `tty`.rstrip, LibTerm.new.dev_path
assert_equal `tty`.rstrip, LibTerm.new.dev_path
		end

		def test_wh
a,rows,columns = `stty -a`.match(/rows (\d+); columns (\d+)/).to_a
wh = [columns, rows].map{|v|v.to_i}
assert_equal wh, LibTerm.new.wh
		end
		
		def test_setattr
attr = LibTerm.new.__getattr
LibTerm.new.__setattr(:now, attr)
		end
end
