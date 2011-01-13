# Ta(Table) is something combine Hash and Struct

# not use name Table. to avoid name confict
class Ta  
	Error = Class.new Exception
	def self.rc klass, const=:Rc, &blk 
		rc = Ta.new
		if klass.const_defined? :Rc
			rc = klass.const_get(:Rc).dup
			klass.__send__ :remove_const, :Rc
		end

		rc.merge! self.new(&blk)
		klass.const_set :Rc, rc
	end # self.rc

	# option: Ta_readonly
	def initialize(table={}, &blk) 
		raise Error, "use Ta.rc module do .. end instead" if Module===table
		table.merge! Ta_eval.new(self.class, &blk).table if blk

		@oph = {}
		@oph[:Ta_readonly] = table.delete(:Ta_readonly)

		@table = {}
		_add(table)
	end # def initialize
	def _table; @table end

	# _add _delete #{{{2
	# parma@ (hash), (key,value)
	def _add(key, value=nil) 
		# check process
		raise "you need call super first in child class in an inheritance." if !@table

		# handle args
		table = Hash===key ? key : {key.to_sym => value}

		# begin
		@table.merge! table

		table.gach do |k,v|
			# already have the method. return
			next if self.respond_to?(k)

			# define method
			self.class.class_eval { 
				define_method(k){ @table[k] } 
			}

			self.class.class_eval { 
				define_method("#{k}="){ |value| @table[k]=value} 
			} unless @oph[:Ta_readonly]
		end

	end

	def _delete(key)
		@table.delete(key)
		self.class.class_eval do
			begin
				remove_method(key)
				remove_method("#{key}=")
			rescue NameError
			end
		end
	end # def _delete

	def marshal_dump #{{{2
		@table
	end

	def marshal_load(x)
		@table = x
		@table.each {|k,v| _add(k,v)}
	end
	# merge == [] []= table eql? #{{{2
	def merge(other) 
		if other.class == self.class
			self.class.new( @table.merge(other._table) )
		else
			raise Error,"the + for #{other}'s class(#{other.class}) is not implemented"
		end
	end

	def merge! other
		ta = merge(other)
		_add(ta._table)
		self
	end

	def ==(other)
		return false unless other.kind_of?(self.class)
		@table == other._table
	end


	def []=(key, value); _add(key.to_sym, value) end
	def [](key); @table[key.to_sym] end
			
	# for uniq
	def hash; @table.hash end
	def eql?(other); @table == other._table end

	def inspect #{{{2
		out = "#<#{self.class}"
		out << "_r" if @oph[:Ta_readonly]
		out << ":"

		first = true
		@table.each do |k,v|
			out << "," unless first
			first = false
			out << " #{k}=#{send(k).inspect}" 
		end

		out << ">"
	end
	alias to_s inspect

	def method_missing(*args) #{{{2
		name, *args = args

		if name =~ /^_/
			return @table.__send__(name[1..-1], *args)
		elsif name =~ /=$/
			arg = args[0]
			raise Error, "Ta readonly. undefine method -- #{name}" if @oph[:Ta_readonly]
			_add(name.to_s.delete(/=$/), arg)
			return arg
		else
			return nil
		end
	end # def method_missing
end # class Ta


#
#   Ta.new do
#     t :a, 1
#   end
#
class Ta_eval  
	attr_reader :table
	def initialize klass, &blk
		@table = {}
		@klass = klass
		instance_eval &blk
	end

	def a key, value=nil, &blk
		if blk
			table = @table
			@table = table[key] = @klass.new
			instance_eval &blk 
			@table = table
		else
			@table[key] = value
		end
	end # def a
end # class Ta_eval
