module Process
	# check if pid is running. 
	# @note for linux only
	# @param [String, Integer] pid process id
	def self.exists?(pid)
		raise NotImplementError unless linux?
		File.exists?("/proc/#{pid}")
	end
end
