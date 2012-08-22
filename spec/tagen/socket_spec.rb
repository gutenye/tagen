require "spec_helper"
require "tagen/socket"

describe BasicSocket do
  describe "#send2, recv2" do
    it do
      s = TCPServer.open("127.0.0.1", 0)
      af, port, host, addr = s.addr
      c = TCPSocket.open(host, port)
      s = s.accept
      c.send2("guten")
      c.send2("tag")

      expect(s.recv2).to eq("guten")
      expect(s.recv2).to eq("tag")
    end
  end

  describe "#send_obj and #recv_obj" do
    it "works" do
      s = TCPServer.open("127.0.0.1", 0)
      af, port, host, addr = s.addr
      c = TCPSocket.open(host, port)
      s = s.accept
      c.send_obj([1,2])

      expect(s.recv_obj).to eq([1,2])
    end
  end
end
