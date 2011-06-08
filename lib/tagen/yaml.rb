require "yaml"

=begin
support #respond_to?(:path). e.g. Pa

  YAML.load(Pa('/tmp/a'))
	YAML.dump("x", Pa('/tmp/a'))
=end
module YAML
	class << self
		alias original_load load
		alias original_dump dump

		# add #path support 
		# @param [String,IO,#path] path
		def load path
			if path.respond_to?(:path)
				path = path.path
				open(path){|f| original_load(f)}

			else
				original_load path
			end
		end

		# add String, #path support 
		# @param [String,IO,#path] path
		def dump obj, path
			if path.respond_to?(:path)
				path = path.path
				open(path, "w+"){|f| original_dump(obj, f)}
			else
				original_dump obj, path
			end
		end

	end
end
