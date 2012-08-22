# used by VimL(Vim Script)
#

# @example
#
# 	vimprint "guten"          -> guten\n
#   vimprint "guten\ntag"     -> guten\n
#
def vimprint(*args)
	args.each do |arg|
		arg = arg.to_s
		arg.split("\n").each {|v| print v}
	end
end

# fix bug 
class <<$stdout
	def flush; end
end
