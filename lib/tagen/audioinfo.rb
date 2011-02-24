=begin
* **gem**: ruby-audioinfo
=end
class AudioInfo
	class << self

		# check if it is a audio file?
		#
		# @param [String] path
		# @return [Boolean] 
		def file? path
			SUPPORTED_EXTENSIONS.include? File.extname(path)
		end

		# get a file's type
		#
		# @param [String] path 
		# @return [String] 
		def type path; File.extname(path) end
	end
end
