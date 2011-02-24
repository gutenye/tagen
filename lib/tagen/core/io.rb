=begin
Additional Method list
----------------------

* `#fd` _alias from fileno_

=end
class IO 

	# a convient function to write text.
	#
	#   use open(path, "w"){|f| f.write(text)}
	#
	# @param [String] path
	# @param [String] text
	# @return [String]
	def self.write(path, text) open(path, "w"){|f| f.write(text)} end

	# a convient function to append text.
	#
	#   use open(path, "a"){|f| f.write(text)}
	#
	# @param [String] path
	# @param [String] text
	# @return [String]
	def self.append(path, text) open(path, "a"){|f| f.write(text)} end

	alias fd fileno
end # class IO
