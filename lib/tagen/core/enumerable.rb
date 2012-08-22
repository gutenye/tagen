module Enumerable
  # Returns an array of every element in enum for each pattern === element
  #
  # @example
  #
  #  a = %w[aa ab bb cc]
  #  a.grep_values(/a./, "bb")   -> ["aa", "ab", "bb"]
  #
  # @return [Array]
  def grep_values(*patterns, &blk)
    patterns.each.with_object([]) {|pat,m|
      m.push *grep(pat, &blk)
    }
  end
end

require "active_support/core_ext/enumerable"
