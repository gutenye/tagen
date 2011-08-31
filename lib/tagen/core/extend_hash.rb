class ExtendHash < Hash
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
