# +exit code+ for shell programming. 
#
# @example
#
#   MyError = Class.new(Exception)
#   MyError.exit_code = 1
#
#   class MyError2 < Exception; @@eixt_code=1 end
#
#   begin
#     ...
#   rescue MyError => e
#     p e.exit_code #=> 1
#  end
class Exception
  class << self
    def exit_code
      @@exit_code 
    end

    def exit_code=(code)
      @@exit_code = code
    end
  end

  def exit_code
    self.class.exit_code
  end
end
