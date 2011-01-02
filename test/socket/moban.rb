#!/usr/bin/env ruby
grequire "socket"

#"GET /index.htm HTTP/1.0\r\n\r\n"
 
#################
# TCP
#################
srv = TCPServer.open("localhost", 8001)
loop do
	Thread.start(srv.accept) do |clt|
		len = clt.recv(4)
		rst = clt.recv(len.unpack("N")[0])
	end
end
#####
clt = TCPSocket.open("localhost", 8001)
clt.send([data.size].pack("N")+data)

#################
# UDP
#################
srv = UDPSocket.open
srv.bind("localhost", 8001)
#####
clt = UDPSocket.open.send("guten", 0, "localhost", 8001)
#####
clt = UDPSocket.open
clt.connect("localhost", 8001)
clt.send("guten", 0)
