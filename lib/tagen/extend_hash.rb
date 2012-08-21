class ExtendHash < Hash
  class << self
    def [](hash)
      case hash
      when ExtendHash
        hash
      when Hash
        eh = self.new
        eh.replace deep_convert(hash)
      else
        raise ArgumentError, "must be a Hash or ExtendHash"
      end
    end

  private
    # convert string key to symbol key.
    # I'm rescurive
    def deep_convert(hash)
      ret = {}
      hash.each { |k,v|
        ret[k.to_sym] = Hash===v ? deep_convert(v) : v
      }
      ret
    end
  end

  def []=(key, value)
    key = key.to_sym if String === key
    super(key, value)
  end

  def [](key)
    key = key.to_sym if String === key
    super(key)
  end

  def method_missing(name, *args)
    if name =~ /=$/
      store(name[0...-1].to_sym, args[0])
    elsif has_key?(name)
      fetch(name)
    else
      raise NoMethodError, "-- :#{name}, #{args.inspect}"
    end
  end
end
