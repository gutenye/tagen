module Net
	class HTTP
		def get1 path, params, initheader={}, &blk
			path = path + "?" + (String===params ? params : URI.encode_www_form(params))
      req = Get.new(path, initheader)
			request req, &blk
		end

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
