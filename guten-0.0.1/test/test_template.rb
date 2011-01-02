#!/usr/bin/ruby
#{{{1
rrequire "../template"
grequire "test"

Gile.rmdir! "tmp"
Gile.mkdir "tmp"
Gile.chdir "tmp"

#}}}1

		Test.skip do
skip :scan
		end

class Test1<Test
		def initialize #{{{1
@src = %~\
my name is @= name >
begin end @[ begin > @[ end >
html escape @== html > 
comment @# comment >
second-template @@= name >
~
test "@src"
echo @src
		end
#}}}1
		def test_scan #{{{1
scan = Template.new(@src).method(:scan)

test "scan"
rst = []
scan.call do |token|
	rst << token
	if token=="\n"
		echo rst
		rst = []
	end
end
echo rst
		end
#}}}1
		def test_compile #{{{1
compile = Template.new(@src).method(:compile)
test "compile"
echo compile.call
		end
#}}}1
		def test_parse #{{{1
tp = Template.new @src
test "parse"

getbinding = proc do
	name = "Guten"
	html = "<html>"
	binding
end

echo tp.parse getbinding.call
		end
#}}}1
end # Test1
