#!/usr/bin/ruby

rrequire "../gdate"
grequire "test"

class Test1 < Test
		def test_leap?
result = [1,4,2000,2004].map do |v|
	Gdate.leap?(v)
end
assert_equal(result, [false,true,false,true])
		end

		def test_days_in_month
result = (1..12).map do |i|
	Gdate.days_in_month(2010,i)
end
assert_equal(result, [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]) 
		end

		def test_days_before_month
result = (1..12).map do |i|
	Gdate.days_before_month(2010,i)
end
assert_equal(result, [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334])
		end

		def test_days_before_year
result = (1..9).map do |i|
	Gdate.days_before_year(i)
end
assert_equal(result, [0, 365, 730, 1095, 1461, 1826, 2191, 2556, 2922])
		end

		def test_ord2date
# 2000.12.31 730495 #730,486
result = [ 1, 730495 ].map{|v| Gdate.ord2date(v)}
assert_equal(result, [
		[1,1,1],
		[2000,12,31],
	])
		end
end
