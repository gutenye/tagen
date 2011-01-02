#!/usr/bin/env ruby

grequire "test/unit"

class Test1 < MiniTest::Unit::TestCase
		def test_assert
assert nil, "nil is nil"
		end

		def test_assert_equal
assert_equal 1, 2
		end

		def test_assert_raises
assert_raises(NameError) { raise RuntimeError, "this is a RuntimeError" }
		end
end
