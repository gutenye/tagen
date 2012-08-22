require "tagen/core/kernel/platform"

module Process
	# check if the pid's process is running. 
	#
	# @note for linux only
	# @param [String, Integer] pid process id
	# @return [Boolean]
	def self.exists?(pid)
		raise NotImplementedError unless linux?
		File.exists?("/proc/#{pid}")
	end
end
