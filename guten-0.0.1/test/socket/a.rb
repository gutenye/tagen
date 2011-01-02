#!/usr/bin/env ruby
grequire "socket"
rrequire "rc"
DEBUG[0]=true

#"GET /index.htm HTTP/1.0\r\n\r\n"
 
#################
# TCP
#################
srv = TCPServer.open( *Rc.socket_addr)
loop do
	Thread.start(srv.accept) do |clt|
		#p clt.recv(10)
		p clt.recv_obj
	end
end
