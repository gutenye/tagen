=begin
Additional Method list
----------------------

* `#fd` _alias from fileno_

=end
class IO 
  class << self

    # a convient function to write text.
    #
    # @example
    #
    #   File.write("/tmp/a", "hello world")
    #
    # @param [String] path
    # @param [String] text
    # @param [Hash] o options
    # @option o [Boolean] :mkdir auto create missing directory in path
    # @return [String]
    def write(path, text, o={}) 
      mkdir_p(File.dirname(path)) if o[:mkdir]

      open(path, "w"){|f| f.write(text)} 
    end

    # a convient function to append text.
    #
    # @example
    #
    #  File.append("/tmp/a", "hello world")
    #
    # @param [String] path
    # @param [String] text
    # @return [String]
    def append(path, text) 
      open(path, "a"){|f| f.write(text)} 
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

end # class IO
