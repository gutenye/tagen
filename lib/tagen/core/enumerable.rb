=begin

== enumerate it

* collect{k,v}  Array#map!
* each_cons(n),{}=>nil each_slice

== retrive value
* [slice]
* first/last(),(n)   Array#first!
* find{} find_index(v),{} find_all Array#find! Array#find_all!
* grep(obj),{=>v} 

* Array#delete(v) delete_at(i) clear()

=end
module Enumerable
  # Returns an array of every element in enum for each pattern === element
  #
  # @return
  def grep_values(*patterns, &blk)
    patterns.each.with_object([]) {|pat,m|
      m.push *grep(pat, &blk)
    }
  end
end

require "active_support/core_ext/enumerable"
