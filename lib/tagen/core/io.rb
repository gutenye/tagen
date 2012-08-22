=begin
Additional Method list
----------------------

* `#fd` _alias from fileno_

=end
class IO 
  class << self
    # a convient function to append text.
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

end # class IO
