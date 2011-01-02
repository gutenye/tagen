# contacts/server.rb

class OServer
	def self.daemon(host, port)
		Process.daemon(nil,true) do
			self.new(host, port)
		end
	end

	attr_reader :_obj
	def initialize(host, port)
		@_obj = __setobj__
		begin
			@srv = TCPServer.open(host, port)
		rescue Errno::EADDRINUSE
			echo "\nError: Another program is using this address (#{host}, #{port})"
			exit
		end

		mutex = Mutex.new

		loop do
			Thread.start(@srv.accept) do |clt|
				loop do
					cmd = clt.recv_obj
					result = nil
					mutex.synchronize do
						begin
							result = @_obj.__send__(*cmd)
						rescue Exception => e
							result = e	
						end
					end # mutex.synchronize
					clt.send_obj(result)
				end # loop 
			end # Thread.start
		end
	end # def initialize
	def self.open(host, port); new(host, port) end

	def __setobj__
		raise NotImplementedError, "return an object"
	end

end # class OServer

class OClient
	undef :send
	def initialize(host, port)
		begin
			@clt = TCPSocket.open(host, port)
		rescue Errno::ECONNREFUSED
			echo "\nError: the server hasn't started yet."
			exit
		end
	end
	def self.open(host, port); new(host,port) end

	def method_missing(name, *args)
		@clt.send_obj([name, *args])
		result = @clt.recv_obj
		raise result if result.kind_of?(Exception)
		result
	end
end # class OClient
