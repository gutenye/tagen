#!/usr/bin/env ruby

# need RUBYOPT=""
require_relative "../lib/guby/kernel"
require "minitest/unit"
MiniTest::Unit.autorun

class Test_1 < MiniTest::Unit::TestCase
	def test_ary_gach
		data = (0..9).to_a

		# return new ary
		b = data.gach do |v|
			1
		end
		assert_equal [1]*10, b

		# :reverse
		b = []
		data.gach :reverse do |v|
			b << v
		end
		assert_equal data.reverse, b

		# 10
		b = []
		data.gach 1 do |v,i|
			b << i
		end
		assert_equal (1..10).to_a, b

		# memo
		b = data.gach({}) do |v,i,m|
			m[v] = 1
		end
		#a = data.zip([1]*10).to_hash
		assert_equal data.zip([1]*10).to_hash, b

		# (&:to_s)
		a = data.map do |v| v.to_s end.to_a
		b = data.gach(&:to_s)
		assert_equal a, b

		# :nil
		rst = data.gach do |v|
			next if v==0
			v
		end
		assert_equal (1..9).to_a, rst
		rst = data.gach :nil do |v|
			next if v==0
			v
		end
		assert_equal [nil]+(1..9).to_a, rst

	end
	def test_hash_gach
		data = {a:1, b:2}

		# return new hash
		b = data.gach do |k,v,m|
			m[k] = 1
			nil
		end
		assert_equal( {a:1, b:1}, b )

		# memo
		b = data.gach [] do |k,v,m|
			m << 1
		end
		assert_equal [1]*2, b
	end
end



