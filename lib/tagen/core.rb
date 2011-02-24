%w(
object/blank object/try 
module/attribute_accessors
class/attribute_accessors
string/strip string/access
numeric/bytes
enumerable
array/access array/wrap 
hash/deep_merge
).each {|n| require "active_support/core_ext/#{n}"}
# some use core/kernel#linux?
%w(
core/kernel
core/object
core/module

core/numeric
core/string
core/array
core/hash

core/time
core/io
core/process

core/pa
).each {|n| require_relative n }
require "time"
require "date"
