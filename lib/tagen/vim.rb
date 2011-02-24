=begin
used by VimL(Vim Script)
=end

# in vim
# 	print "guten" => guten\n
#   print "guten\ntag" => guten\n
# each_str.split("\n")
def vimprint *args
	args.each do |arg|
		arg = arg.to_s
		arg.split("\n").each {|v| print v}
	end
end

# fix bug 
class <<$stdout
	def flush; end
end
