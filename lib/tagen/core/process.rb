require "tagen/core/kernel/platform"

module Process
	# Check if the pid's process is running. 
	# @note for linux only
	#
	# @param [Integer] pid process id
	# @return [Boolean]
	def self.exists?(pid)
		raise NotImplementedError unless linux?
		File.exists?("/proc/#{pid}")
	end
end
