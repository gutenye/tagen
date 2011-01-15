$: << "."
require "version"

Gem::Specification.new do |s|
	s.name = "guten"
	s.version = VERSION::STRING
	s.summary = "guten's ruby extension"

	s.author = "guten"
	s.email = "ywzhaifei@gmail.com"
	s.homepage = nil

	s.files = `git ls-files`.split("\n")
end
