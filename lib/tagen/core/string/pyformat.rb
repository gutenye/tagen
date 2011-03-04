=begin
== Overview 
a python like format

1. "this is #{guten}" 											
2. "this is {guten}".format(guten: 'x')

== Usage
	require "tagen/core"
	"it costs {:.2f} dollar".format(1.123) #=> "it costs 1.12 dollar"

== Examples
	"{:.2f} {name:.2f} {{name}}" ¦ str#format(1, name:2) 

	"{} {}".format(1,2)
	"{a} {b}".format(1, 2, b:3)

== Specification
	format_spec ::=  [[fill]align][sign][#][0][width][,][.precision][type]
	fill        ::=  <a character other than '}'> default is " " 
	align       ::=  "<" | ">" | "=" | "^" 	default is >.  = is padding after sign. eg. +000000120
	sign        ::=  "+" | "-" | " "
	#						::=  <prefix 0b 0o 0x>
	0						::=  <zero_padding>  equal to fill is 0
	,						::=  <comma_sep> also type n
	precision		::=  string truncate with 
	type        ::=  s c b o d x X ¦ f/F g/G e/E n % 

	f/F 	fixed point. nan/NAN inf/INF
	e/E 	exponent notation. 
	g/G 	gernal format.  1.0 => 1
	n 		number. thounds sep based on  local setting


== Resources
* http://docs.python.org/py3k/library/string.html#formatstrings


=end
class PyFormat
	Error = Class.new Exception
	EFormatSpec = Class.new Error
	EFieldName 	= Class.new Error

	# @param [String] fmt
	def initialize fmt
		@fmt = fmt
	end
	
	# format a string
	#
	# @param [Object] *args
	# @return [String]
	def format *args
		# if 'field' in argh
		#   return argh[field]
		# else
		#   return args.shift
		# end

		# args -> argh and args
		argh = Hash===args[-1] ? args.pop : {}

		# "{0:.5f}"
		pat = /{{.*?}} | { (.*?)? (?: :(.*?) )? } /x
		ret = @fmt.gsub(pat) do |m|
			if m.start_with? "{{"
				m
			else
				field, spec = $1, $2
				field = field.to_sym

				if argh.has_key? field
					arg = argh[field]
				else
					arg = args.shift

					# can't use if arg==nil then .. 
					#
					# class Guten
					#   def <=> other
					#     "{}".format(self)
					#   end
					# 
					# => SystemStackError
					#
					if NilClass === arg then raise EFieldName, "not enought arguments --#{args}" end
				end

				Field.parse spec, arg
			end
		end
		ret
	end

	class Field
		PAT = /^ 
					(?: (?<fill>[^}]+)?  (?<align>[<>=^]) )? 
					(?<sign>[ +-])? 
					(?<alternate>\#)? 
					(?<zero_padding>0)? 
					(?<width>\d+)? 
					(?<comma_sep>,)? 
					(?: \.(?<precision>\d+) )? 
					(?<type>[bcdeEfFgGnosxX%])? /x


		def self.parse spec, arg
			f = self.new 
			f.parse_spec spec if spec
			f.format arg
		end

		def initialize
			# default options
			@o = {
				fill: " ",
				align: ">",
				sign: "-",
				alternate: false,
				zero_padding: false,
				width: 0,
				comma_sep: false,
				precision: nil,
				type: nil,
			}
		end

		# parse a spec string
		#
		# 	parse_spec "this is {:.2f}"
		# 	return @o
		#
		# @param [String] spec
		# @return [nil] 
		def parse_spec spec
			matched = PAT.match(spec)
			raise EFormatSpec, spec if not matched
			matched = matched.to_hash

			# merge @o and matched
			@o.each do |k,v|
				@o[k] = matched[k] ? matched[k] : v
			end

			# handle keys 
			@o = @o.each.with_object({}) do |(k,v),o|
				case k 
				when :width, :precision
					o[k] = v.to_i if v
				when :zero_padding
					if v
						o[:fill] = "0"
					end
				when :precision
					o[:precision] = 1 if v<1
				else
					o[k] = v
				end
			end

			if @o[:align] == "="
				@o[:fill] = "0"
				@o[:sign] = "+"
			end

		end

		# format a <#Field> by @o
		#
		# @param [Object] arg
		# @return [String]
		def format arg
			# arg is int str ..
			# ret is str.
		
			case arg
			when Integer	
				@o[:type] ||= 'd'
			else  # default is s
				@o[:type] ||= 's'
			end
			
			ret = case @o[:type] 
			when 's'
				arg = arg.to_s
				@o[:precision] ? arg[0...@o[:precision]] : arg
			when 'c'
				arg.chr

			when 'b','o','d','x','X'
				arg = arg.to_i

				case @o[:type]
				when 'b'
					ret1 = arg.to_s 2
					ret1 = do_comma ret1
					@o[:alternate] ? '0b'+ret1 : ret1
				when 'o'
					ret1 = arg.to_s 8
					ret1 = do_comma ret1
					@o[:alternate] ? '0'+ret1 : ret1
				when 'd'
					ret1 = arg.to_s 10
					do_comma ret1
				when 'x', 'X'
					ret1 = arg.to_s 16
					ret1.upcase! if @o[:type]=='X'
					ret1 = do_comma ret1
					@o[:alternate] ? "0#{@o[:type]}"+ret1 : ret1
				end

			# for float, need handle 'precision'
			when 'f','F','g','G','e','E', '%'
				type = @o[:type]

				num = arg.to_f

				if type=='%'
					num = num*100 
					type = 'g'
				elsif type=='F'
					type = 'f'
				end

				# remove 0 1.00000
				if type=='f'
					sa, sb = num.to_s.split('.')
					prec = sb.length
					@o[:precision] = prec if not @o[:precision]
				elsif type=='e'
					# not implement yet
				end

				spec = "%"
				spec += '.' + @o[:precision].to_s if @o[:precision]
				spec += type

				ret1 = spec % num

				# '%g' % 1.0 => 1

				# 'comma_sep'
				if not %w(g G).include? type
					a, b = ret1.split('.') 
					a = do_comma a
					ret1 = b==nil ? a : a+'.'+b
				end

				ret1 += '%' if @o[:type]=='%'
				ret1

			end # case

			## sign
			if @o[:sign] != '-'
				sign = arg.to_f>=0 ? @o[:sign] : '-'
				ret = sign+ret
			end


			## width
			n = @o[:width] - ret.length
			if n > 0
				fill = ''
				@o[:fill].chars.cycle do |c|
					fill << c
					break if fill.length == n
				end

				ret = case @o[:align]
				when '>' then fill + ret
				when '<' then ret + fill
				when '^' then fill[0...fill.length/2] + ret + fill[fill.length/2..-1]
				when '=' then ret[0] + fill + ret[1..-1]
				end

			end
			

			ret
		end # def format

	private
		# convert '1234' -> ['1', '234'] -> '1,234'
		#
		# loop
		#   [l:h]
		#   break if h==length 
		#   l = h ; h += 3
		def do_comma src
			# [l:h]
			l = 0
			h = (src.length % 3)
			srcs = []

			loop do
				pice = src[l...h]
				srcs << pice  if not pice==""
				break if h == src.length 
				l = h ; h += 3
			end

			srcs.join ','
		end
	end # class Field
end # class PyFormat

class String
	def format(*args) PyFormat.new(self).format *args end
end


# vim:foldnestmax=4