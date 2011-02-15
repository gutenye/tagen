$: << "."
require "version"

Gem::Specification.new do |s|
	s.name = "tagen"
	s.version = VERSION::IS
	s.summary = "a core and extra extension to ruby library"
	s.description = <<-EOF
an extension to ruby core and gem library. use some active_support/core_ext, but smaller than active_support. active_support is mainly target to Rails, but tagen is target to generic ruby development.
	EOF

	s.author = "guten"
	s.email = "ywzhaifei@gmail.com"
	s.homepage = nil

	s.files = `git ls-files`.split("\n")

	s.add_dependency "activesupport"
end
