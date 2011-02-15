class AudioInfo
	class << self
		def file? path
			SUPPORTED_EXTENSIONS.include? Pa(path).ext
		end
		def type path; Pa(path).ext end
	end
end
