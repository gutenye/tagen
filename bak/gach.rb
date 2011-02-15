module Enumerable  #¤enumrable
	# @gach
	# args@ 10 memo 
	# o@ :reverse
	#
	def gach *args, &blk
		# can't use to_o. wie memo is {} 
		
		# handle args 
		start = 0
		has_memo = false
		memo = Array===self ? [] : self.dup # [] or {..}.dup
		o = {}
		args.each do |arg|
			case arg
			when Fixnum
				start = arg
			when Symbol
				o[arg] = true
			else
				memo = arg
				has_memo = true
			end
		end

		obj = self.dup
		obj = obj.reverse if o[:reverse]

		if Array === self
			obj.each_with_index do |v,i| 
				begin
					blk_rst = blk.call(v, i+start, memo) 
				rescue ArgumentError  # for gach(&:to_s)
					blk_rst = blk.call(v) 
				end

				unless has_memo
					if o[:nil] then memo << blk_rst else memo << blk_rst if not blk_rst.nil?  end
				end

			end
		elsif Hash === self
			each do |k,v| 
				blk.call(k, v, memo)
			end
		end

		memo
	end # def gach
	def gach! *args,&blk
		self.replace gach(*args, &blk)
	end
end #module Enumerable
