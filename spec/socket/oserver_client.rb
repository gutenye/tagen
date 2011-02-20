#!/usr/bin/ruby

rrequire "../../socket"
rrequire "rc"

class Client < OClient
end

$log.debug "TEST OSERVER"
table = Client.open *Rc.socket_addr

$log.debug "table.a=11"
#table.a=11

$log.debug "table.a"
#p table.a

ary = table.a

ary[0]=2

#p table.a
table.a[0]=2
p table.a
