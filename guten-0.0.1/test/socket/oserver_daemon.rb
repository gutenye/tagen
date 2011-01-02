#!/usr/bin/ruby
grequire "test"
rrequire "../../socket"

DEBUG[0]=true


# start restart stop

$addr = ["localhost", 8002]

class Server < OServer
		def __setobj__
Gable.new
		end
end

class Client < OClient
end

Server.daemon(*$addr)

