class Numeric 
	# equivalent to `a.fdiv(b).ceil`. +1
	#
	# @param [Numeric] num
	# @return [Numeric]
	def div2(num)
		d, m = divmod(num)
		d + (m==0 ? 0 : 1)
	end
end

require 'active_support/core_ext/numeric/bytes'
