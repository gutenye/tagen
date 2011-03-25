require 'erb'

class ERB
	alias original_result result

	# add locals support
	#
	# @example
	#  erb = Erb.new("<%=a%>")
	#  erb.result(nil, a: 1) #=> "1"
	#
	# @param [Hash,OpenOption] locals
	def result bind=nil, locals={}
		bind ||= TOPLEVEL_BINDING
		if locals.empty?
			original_result bind
		else
			result_with_locals bind, locals
		end
	end

	private
	def result_with_locals bind, locals
		map_method = locals.class.to_s=="OpenOption" ? :_map : :map

		@locals = locals
		evalstr = <<-EOF
def run_erb
	#{locals.send(map_method){|k,v| %~#{k} = @locals[ #{Symbol===k ? ':' : ''}'#{k}' ]~}.join(';')}
	#{self.src}
	_erbout
end
		EOF
		eval evalstr
		run_erb
	end

end
