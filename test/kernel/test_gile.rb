#!/usr/bin/env ruby
require "minitest/unit"
require_relative "../../kernel/gile"
require_relative "../../kernel"
MiniTest::Unit.autorun


class Test_1 < MiniTest::Unit::TestCase
	def test_1
		Gile.truncate("/tmp/a")
	end

end # class Test1
