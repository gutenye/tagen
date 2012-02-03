require "tagen/core"

class Dir
	class << self
		def empty? path
			Dir.entries(path).sort == %w(. ..)
		end
	end
end

RSpec.configure do |config|
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  alias :silence :capture
end

module Kernel 
private

  def xdescribe(*args, &blk)
    describe *args do
      pending "xxxxxxxxx"
    end
  end

  def xcontext(*args, &blk)
    context *args do
      pending "xxxxxxxxx"
    end
  end

  def xit(*args, &blk)
    it *args do
      pending "xxxxxxxx"
    end
  end
end
