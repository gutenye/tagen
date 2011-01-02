#!/usr/bin/env ruby

rrequire "../test"

class Test1 < Test
		def test_assert
assert nil, "guten"
		end

		def test_assert_equal
assert_equal 1,2
		end

		def test_assert_raises
assert_raises(RuntimeError, NameError) {raise TypeError, "this is a TypeError"}
		end

		def test_1
raise "tag"
		end
end



