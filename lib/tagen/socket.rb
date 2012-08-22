require "socket"

class BasicSocket
  MessageLengthError = Class.new(StandardError)
  MessageUnderflow = Class.new(StandardError)

  MAXLEN  = 65535
  LEN_LEN = [0].pack("N").size

  # Send a message over the socket. The message is like a datagram rather
  # than a stream of data.
  def send2(message)
    len = message.length
    if len > MAXLEN
      raise MessageLengthError, "MAXLEN exceeded: #{len} > #{MAXLEN}"
    end
    send([len].pack("N"), 0)
    send(message, 0)
  end

  # Receive a message from the socket. Returns +""+ when there are no
  # more messages (the writer has closed its end of the socket).
  # Yields each time more data is received, even if partial. This can
  # be used for a progress indicator.
  def recv2
    if (data = recv(LEN_LEN))
      if data.empty?
        ""
      else
        len = data.unpack("N")[0]
        if len > MAXLEN
          raise MessageLengthError, "MAXLEN exceeded: #{len} > #{MAXLEN}"
        end

        msg = ""
        part = nil
        while (delta = len - msg.length) > 0 and (part = recv(delta))
          if part.length == 0
            raise MessageUnderflow,
              "Peer closed socket before finishing message --" +
              " received #{msg.length} of #{len} bytes:\n" +
              msg[0..99].unpack("H*")[0] + "..."
          end
          yield part if block_given?
          msg << part
        end
        msg.empty? ? nil : msg
      end
    end
  end

  def send_obj(obj)
    send2 Marshal.dump(obj)
  end

  def recv_obj
    Marshal.load recv2
  end
end

class Socket
  class <<self
    # pack human-readable address to Socket address
    #
    # @example
    #
    # 	addr("192.168.1.1") #=> "\xC0\xA8\x01\x01"
    #
    # @return [String] address used by Socket
    # @see unaddr
    def addr(str) 
      str.split(".").map{|v|v.to_i}.pack("CCCC") 
    end

    # unpack to humna-readable address from  Socket address 
    #
    # @example
    #
    # 	unaddr("\xC0\xA8\x01\x01") #=> "192.168.1.1"
    #
    # @return [String] human readable address
    def unaddr(str)
      str.unpack("CCCC").join(".") 
    end
  end
end
