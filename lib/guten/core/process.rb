module Process  # Daemon
class Daemon 
	def initialize(chdir=false, close=false, &blk)
		@@pid_pa = "/var/run/guten/#{File.basename($0)}.pid"

		require "gutopt"
		Gutopt.parse do |o|
			o.on(""){echo o.help}
			o.on("start", "start the daemon"){Daemon.start(chdir, close, &blk)}
			o.on("stop", "stop the daemon"){Daemon.stop}
			o.on("restart", "restart the daemon"){Daemon.restart(chdir, close, &blk)}

			o.doc
			o.doc "store pid at /var/run/guten/<prgname>.pid"
		end
	end # def initialize

	class << self
	def __cleanup
		Pa.rm @@pid_pa
	end

	def start(chdir, close, &blk)
		if Pa.exist?(@@pid_pa)
			pid = gread(@@pid_pa)
			return if Process.exists?(pid)
		end

		Process.daemon(chdir, close)
		gwrite(@@pid_pa, Process.pid)
		trap(:TERM){__cleanup; exit}
		at_exit{__cleanup}

		blk.call
	end # def start

	def stop
		return unless File.exist?(@@pid_pa)
		pid = gread(@@pid_pa).to_i
		begin
			Process.kill(:TERM, pid)
		rescue Errno::ESRCH => e
			echo "#{e} #{pid}"
			__cleanup
		end
	end # def stop

	def restart(chdir, close, &blk)
		self.stop
		sleep 1
		self.start(chdir, close, &blk)
	end
	end # class <<self
end # class Daemon
end # module Process
module Process
class <<self
	alias daemon_ daemon
	# add &block for Process.daemon
	#
	# === Examples
	#  Process.daemon(nil,true) do
	#    # run code here
	#  end
	#
	#  $ end --help
	#    end {start, stop, restart}
	def daemon(chdir=false, close=false, &blk)
		if blk
			Daemon.new(chdir, close, &blk)
		else
			self.daemon_(chdir, close)
		end
	end # def daemon
	def exists?(pid)
		File.exists?("/proc/#{pid}")
	end
end # class <<self
end # module Process
