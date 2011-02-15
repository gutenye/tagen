require "logger"

logfile = $socket_env == :development ? "/dev/null" : "/log/rb_socket"
$log = Logger.new logfile

class IO
	class Error < Exception; end
end

class BasicSocket
	# data: | 1 | 2 | 256 | byte, each for isdone len data
	def send_obj obj
		begin
			data = Marshal.dump(obj)
		rescue TypeError # #<proc>
			data = Marshal.dump(nil)
		end

		$log << "[TOTAL] send_obj_data: #{obj.inspect}; len:#{data.size}; times: #{data.size.div2(256)}\n"
		(last=data.size.div2(256)).times do |i|
			if last==i+1
				isdone = 1
				len = data.size - i*256
			else
				isdone = 0
				len = 256
			end

			$log << "send_obj... times:#{i}, isdone:#{isdone}, len:#{len}, data:#{data[i*256, len]}"
			send [isdone].pack("c"), 0
			send [len].pack("n"), 0
			send data[i*256, len], 0
			$log << "...send_obj_done\n"
		end
	end

	def recv_obj
		data = ""
		loop do
			$log << "recv_obj..."
			isdone = recv(1).unpack("c")[0]==1 ? true : false
			len = recv(2).unpack("n")[0]
			data << (recved=recv(len))
			$log << "data: #{recved} ...recv_obj_done\n"
			break if isdone		
		end
		$log << "[TOTAL] recv_obj_data: #{Marshal.load(data).inspect}\n"
		Marshal.load(data)
	end

end # class BasicSocket


class String
	def addr() self.split(".").map{|v|v.to_i}.pack("CCCC") end
	def unaddr() self.unpack("CCCC").join(".") end
end

require_relative "socket/oserver"
