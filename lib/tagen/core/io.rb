require "tagen/core/array/extract_options"

class IO 
  class << self
    # Extends IO#write with :mkdir option
    #
    # @overload write(name, string, [offset], [open_args])
    #   @param [Hash] open_args 
    #   @option open_args [Boolean] :mkdir auto create missing directory in path
    def write_with_tagen(name, string, *args)
      (offset,), o = args.extract_options
      mkdir_p(File.dirname(name)) if o[:mkdir]

      write_without_tagen(name, string, offset, o)
    end

    alias write_without_tagen write
    alias write write_with_tagen

    # A convient method to append a file.
    #
    # @overload append(name, string, [offset], [open_args])
    #   @param [Hash] open_args 
    #   @option open_args [Boolean] :mkdir auto create missing directory in path
    #  
    # @example
    #
    #  File.append("/tmp/a", "hello world")
    #
    # @see write
    def append(name, string, *args)
      (offset,), o = args.extract_options
      o[:mode] = "a"

      write(name, string, offset, o)
    end

  private

    # @param [Hash] o options
    # @option o [Fixnum] :mode (0775)
    def mkdir_p(path, o={})
      return if File.exists?(path)

      o[:mode] ||= 0775

      stack = []
      until path == stack.last
        break if File.exists?(path)
        stack << path
        path = File.dirname(path)
      end

      stack.reverse.each do |p|
        Dir.mkdir(p)
        File.chmod(o[:mode], p)
      end
    end
  end

  alias fd fileno
end
