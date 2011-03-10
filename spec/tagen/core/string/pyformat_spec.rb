require "spec_helper"
#format_spec ::=  [[fill]align][sign][#][0][width][,][.precision][type]


describe PyFormat do
	before :all do
	# from go-src/fmt
	@test_datas = [

	# type        ::=  s c b o d x X ¦ f/F g/G e/E n % 
	[ "{}", 	1, 		"1"],
	[ "{:s}", 1, 		"1"],
	[ "{:c}", 'a', 	"a" ],
	[ "{:b}", 0b10, "10" ],
	[ "{:o}", 010, 	"10" ],
	[ "{:x}", 0xa, 	"a" ],
	[ "{:X}", 0xa, 	"A" ],
	[ "{:f}", 1, 		"1.0"],
	[ "{:F}", 1, 		"1.0"],
	[ "{:e}", 1,	 "1.000000e+00" ],
	[ "{:E}", 1,	 "1.000000E+00" ],
	[ "{:g}", 1, 		"1"],
	[ "{:g}", 1e6, "1e+06" ],
	[ "{:G}", 1e6, "1E+06" ],
	#[ "{:n}" ],
	[ "{:%}", 1, 	"100%" ],

	# width 
	[ "{:5s}", 	1234, " 1234"],
	[ "{:3s}", 	1234, "1234"],
	[ "{:.3s}", 1234, "123"],

	[ "{:3f}",	1.123, "1.123"],
	[ "{:.1f}", 1.123, "1.1"],
	[ "{:4.1f}", 1.123, " 1.1"],

	# fill align
	[ "{:0<2}", 1, "10"],
	[ "{:0>2}", 1, "01"],
	[ "{:0^4}", 1, "0100"],
	[ "{:02}", 1, "01"],

	# sign
	[ "{:+}", 1, "+1"],
	[ "{: }", 1, " 1"],
	[ "{:-}", 1, "1"],

	[ "{:+3}", 1, " +1"],
	[ "{:=3}", 1, "+01"],

	# alternate
	[ "{:#b}", 0b1, "0b1"],
	[ "{:#4b}", 0b1, " 0b1"],
	[ "{:#o}", 01, "01"],
	[ "{:#x}", 0x1, "0x1"],

	# comma
	[ "{:,}", 1234, "1,234"],

	] # 
	end

	it "parse_spec. PAT.match()" do
		a = "0> #07,.7f"
		b = [ '0', '>', ' ' ]+%w(# 0 7 , 7 f)
		PyFormat::Field::PAT.match(a).to_a[1..-1].should == b
	end

	it "parse: '{} {}'" do
		[
			[ "{} {}", 			[1, 2], 			"1 2" 			],
			[ "{a} {{b}}", 	[{a:1}], 			"1 {{b}}" 	],
			[ "{} {a} {b}", [1,2,3,{b:4}],"1 2 4"			],
		].each do |src, args, rst|
			src.format(*args).should == rst
		end
	end

	it "@test_datas.each do format" do
		@test_datas.each do |fmtsrc, a, b|
			#puts "#{fmtsrc.inspect}: #{a.inspect}, #{b.inspect}"
 			fmtsrc.format(a).should == b
		end
	end
end
