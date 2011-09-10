$: << File.expand_path("../lib", __FILE__)
require "tagen/version"

Gem::Specification.new do |s|
	s.name = "tagen"
	s.version = Tagen::VERSION::IS
	s.summary = "a core and extra extension to ruby library"
	s.description = <<-EOF
an extension to ruby core and gem library. use some active_support/core_ext, but smaller than active_support. active_support is mainly target to Rails, but tagen is target to generic ruby development.
	EOF

	s.author = "Guten"
	s.email = "ywzhaifei@gmail.com"
	s.homepage = "http://github.com/GutenYe/tagen"
	s.rubyforge_project = "xx"

	s.files = `git ls-files`.split("\n")
end
