#!/usr/bin/ruby


grequire "test"
rrequire "../getopt"


class Test1<Test
		def test_on
opts = Getopt.new do
	banner "./guten [options]"

	on(""){}
	on("a <old> [new]"){}

	separator
	on("-a <guten> [tag]"){}
	on("-b <guten> [*tag]"){}
	on("-c <guten> <*tag>"){}

	separator
	on("-a", "--a <guten>"){}
end

####### @opts
assert_equal( opts.instance_variable_get(:@opts).map{|v| v[0...-1]}, 
	[		[["--help"], [], false], 
			[[], [], false], 
			[["a"], [:require, :optional], false], 
			[["-a"], [:require, :optional], false], 
			[["-b"], [:require, :optional], true], 
			[["-c"], [:require, :require], true], 
			[["-a"], [:require], false], [["--a"], [:require], false]
	])

###### @help
assert_equal( opts.instance_variable_get(:@help), 
	[ 	"./guten [options]", 
			[nil, "--help", "show this help message"], 
			["", nil, nil], 
			["a <old> [new]", nil, nil], 
			"", 
			["-a <guten> [tag]", nil, nil],
			["-b <guten> [*tag]", nil, nil], 
			["-c <guten> <*tag>", nil, nil], 
			"", 
			["-a <guten>", "--a <guten>", nil]
	])
		end

		def test_parse_nameopt
opts = Getopt.new do 
	on("start <old> [new]"){|*args| args}
end

######## 1
argv = %w(start guten)
assert_equal opts.parse(argv), ["guten", nil]
assert_equal argv, []

######## 2
argv = %w(start guten tag ich)
assert_equal opts.parse(argv), ["guten", "tag"]
assert_equal argv, ["ich"]
		end

		def test_parse_shortopt
result = {}
opts = Getopt.new do 
	on("-a"){result[:a]=true}
	on("-b"){result[:b]=true}
	on("-c <name>"){|name| result[:c]=name}
	on("-d [*args]"){|*args| result[:d]=args}
end

######## 1
argv = %w(-abc guten tag)
opts.parse(argv)
assert_equal(result, 
	{	a: true,
		b: true,
		c: "guten",
	})
assert_equal(argv, ["tag"])

######## 2
argv = %w(-d guten tag ich); result={}
opts.parse(argv)
assert_equal(result, {d:["guten", "tag", "ich"]})
assert_equal(argv, [])
		end

end
