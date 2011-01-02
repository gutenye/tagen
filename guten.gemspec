$: << File.expand_path("../lib", __FILE__)
require "guten/version"

spec = Gem::Specification.new do |s|
	s.name = "guten"
	s.version = VERSION
	s.summary = "guten's ruby extension"

	s.files = `git ls-files`.split("\n")
end
