class IO 
	# a convient function to write text.
	#   use open(path, "w"){|f| f.write(text)}
	def self.write(path, text) open(path, "w"){|f| f.write(text)} end
	# a convient function to append text.
	#   use open(path, "a"){|f| f.write(text)}
	def self.append(path, text) open(path, "a"){|f| f.write(text)} end

	alias fd fileno
end # class IO
