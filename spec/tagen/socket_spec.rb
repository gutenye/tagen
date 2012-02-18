require "spec_helper"
require "tagen/socket"

describe BasicSocket do
  describe "#send2 and #recv2" do
    it "works" do
      s = TCPServer.open("127.0.0.1", 0)
      af, port, host, addr = s.addr
      c = TCPSocket.open(host, port)
      s = s.accept
      c.send2("guten")
      c.send2("tag")
      s.recv2.should == "guten"
      s.recv2.should == "tag"
    end
  end

  describe "#send_obj and #recv_obj" do
    it "works" do
      s = TCPServer.open("127.0.0.1", 0)
      af, port, host, addr = s.addr
      c = TCPSocket.open(host, port)
      s = s.accept
      c.send_obj([1,2])
      s.recv_obj.should == [1,2]
    end
  end
end
