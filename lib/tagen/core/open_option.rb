=begin

main purpose of this Class is provide an option support.

Example:
	
	o = OpenOption.new
	o.name = 'alice'
	p o.name #=> 'alice'

	o.force = true
	p o.force? #=> true

Overview:

	o = OpenOption.new

define value, they are all the same

	o.key = value
	o[:symbol] = value
	o["string"] = value

access value, they are all the same

	o[:symbol]
	o["string"]
	o.key
	o.key?

access hash method, some are special

	o._keys #=> [:a]
	o._merge(a: 1) #=> a new <#OpenOption a: 1>
	o._merge!(a: 1) #=> self

access data

	o._data #=> {a: 1} 


new(data={})
------------

data's key can be string or symbol, but internal store key is use symbol.

	data = { "a" => 1 }
same as
	data = { :a => 1 }

it is a deep convertion of Hash.

	a = { a: {b: 1} }
	o = OpenOption.new(a)
	o #=> <#OpenOption a: <#OpenOption b:1> > 
	# so you can access b by o.a.b




=end
class OpenOption

	class <<self
		# I'm rescurive
		# deep convert hash to OpenOption
		def convert_hash data, ret={}
			data.each do |k,v|
				if Hash === v
					new_v = self.new(v)
					ret[k.to_sym] = new_v
					convert_hash(data[k], ret[k.to_sym])
				else
					ret[k.to_sym] = v
				end
			end
			ret
		end
	end

	attr_accessor :_data

	def initialize(data={})
		@data = OpenOption.convert_hash(data)
	end # def initialize

	def _data() @data end
	def _data=(data) @data = data end

	# method return value
	# _method goes to Hash
	# method? return !!value
	# method= define a new key
	def method_missing(name, *args, &blk) 
		if name =~ /^_(.*)/
			return @data.send($1.to_sym, *args, &blk)
		elsif name =~ /(.*)\?$/
			return !!@data[$1.to_sym]
		elsif name =~ /(.*)=$/
			@data[$1.to_sym] = args[0]
		else
			return @data[name.to_sym]
		end
	end

	def marshal_dump 
		@data
	end

	def marshal_load data
		@data = data
	end

	def ==(other)
		return false unless other.kind_of?(self.class)
		@data == other._data
	end

	def eql?(other) @data == other._data end

	def []=(key, value) @data[key.to_sym] = value end

	def [](key) @data[key.to_sym] end
			
	def hash() @data.hash end

	def dup
		@data.dup
	end

	def inspect
		out = "#<#{self.class} "
		out << @data.map{|k,v| "#{k}: #{v.inspect}"}.join(', ')
		out << ">"
	end

	alias to_s inspect

	def _replace data
		@data = data
	end

	def _merge *args
		self.class.new @data.merge(*args)
	end

	def _merge! *args
		@data.merge! *args
		return self
	end

end
