#!/usr/bin/env ruby
grequire "socket"
rrequire "rc"

#"GET /index.htm HTTP/1.0\r\n\r\n"
 
DEBUG[0]=true
#################
# TCP
#################
clt = TCPSocket.open( *Rc.socket_addr )
data = ARGV[0]
#clt.send_obj(data)
clt.send_obj(data)


