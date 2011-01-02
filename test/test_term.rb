#!/usr/bin/env ruby
#{{{1
rrequire "../term"
grequire "test"
#}}}1
		Test.skip do
skip :Term
#skip :setattr

#skip :LineTerm
		end


class Test_Term < Test
		def test_attr #{{{1
test "Term#attr"
echo Term.attr
		end
#}}}1
		def test_setattr #{{{1
test "input with -echo and restore echo"
Term.setattr :_echo do
	necho "passwd: "
	necho "\nyour passwd is:", gets
	necho "-- Press Enter to continue. --"
	gets
	echo
end
		end 
#}}}1
		def test_non_canonical #{{{1
Term.setattr :_echo, :_canonical, :_opost do |t|
	while (key=t.getkey) do
		case key
		when "s"
			t.save{
				t.mvy -2
				t.necho "guten"
			}
	
		when :backspace
			t.backspace

		when "h" 
			t.mvx -1	
		when "l"
			t.mvx 1 
		when "j"
			t.mvy 1
		when "k" 
			t.mvy -1

		else
			t.necho key
		end
	end
end # Term.setattr
		end # def test_non_canonical
#}}}1
end # class Test_Term

class Test_LineTerm < Test
		def test_readline
lterm = LineTerm.new 

loop do
	lterm.readline "guten$ "
end
		end
end
