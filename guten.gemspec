$: << File.expand_path("../lib", __FILE__)
require "guten/version"

spec = Gem::Specification.new do |s|
	s.name = "guten"
	s.version = VERSION
	s.summary = "guten's ruby extension"
	s.author = "guten"
	s.email = "ywzhaifei@gmail.com"

	s.files = `git ls-files`.split("\n")
end
