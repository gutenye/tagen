#!/usr/bin/ruby
rrequire "../../socket"
rrequire "rc"

class Server < OServer
		def __setobj__
table = Gable.new
table.a = [1]
table
		end
end

Server.new(*Rc.socket_addr)
