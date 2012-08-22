class IO 
  class << self
    # A convient method to append a file.
    #
    # @overload append(name, string, [offset], [open_args])
    #
    # @example
    #
    #  File.append("/tmp/a", "hello world")
    #
    # @see IO.write
    def append(name, string, *args)
      (offset,), o = args.extract_options
      o[:mode] = "a"

      write(name, string, offset, o)
    end
  end

  alias fd fileno
end
