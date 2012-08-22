require "net/http"

module Net
  class HTTP
    class << self

      # support params
      #
      # @param [String Hash] params Hash by URI.encoding_www_form
      # 
      # @example
      #
      # 	get1("http://www.google.com/search", "&q=foo")
      # 	get1("http://www.google.com/search", {"q" => "foo"} )
      #
      def get1 path, params, initheader={}, &blk
        path = path + "?" + (String===params ? params : URI.encode_www_form(params))
        req = Get.new(path, initheader)
        request req, &blk
      end

      # support params
      #
      # @see get1
      def post1 path, params, initheader={}, &blk
        req = Post.new(path, initheader)
        if String===params
          req.body = params
          req.content_type = 'application/x-www-form-urlencoded'
        else
          req.set_form_data(params)
        end
        request req, &blk
      end

    end
  end
end
