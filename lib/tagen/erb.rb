require "erb"

class ERB
	# add locals support
	#
	# @example
	#  erb = Erb.new("<%=a%>")
	#  erb.result(nil, a: 1) #=> "1"
	#
	# @param [Hash,OpenOption] locals
	def result_with_tagen(bind=nil, locals={})
		bind ||= TOPLEVEL_BINDING
		if locals.empty?
			result_without_tagen bind
		else
			result_with_locals bind, locals
		end
	end

	alias result_without_tagen result
  alias result result_with_tagen

private
	def result_with_locals(bind, locals)
		@locals = locals
		evalstr = <<-EOF
def run_erb
	#{locals.map{|k,v| %~#{k} = @locals[ #{Symbol===k ? ':' : ''}'#{k}' ]~}.join(';')}
	#{self.src}
	_erbout
end
		EOF
		eval evalstr
		run_erb
	end
end
