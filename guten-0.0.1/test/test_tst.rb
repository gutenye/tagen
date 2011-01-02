#!/usr/bin/env ruby
rrequire "../tst"
grequire "test"

class Test_1 < Test
		def test_compile
tst = TST.open("resources/a.tst")
str = %~guten=1 tag="guten 'tag'" ich='i ok'%~

assert_equal({:guten=>"1", :tag=>"guten 'tag'", :ich=>"i ok"}, tst.send(:compile, str))
		end

		def test_1
tst = TST.open("resources/a.tst")
assert_equal [["guten", "tag"], ["ich", "bin"]], tst.list
		end

		def test_all
tst = TST.open("resources/all.tst")
assert_equal [["guten", "1"], ["tag", "2"], ["ich", "3"]], tst.list
		end
end

