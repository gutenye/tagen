Kernel.load File.expand_path("../lib/tagen/version.rb", __FILE__)

Gem::Specification.new do |s|
	s.name = "tagen"
	s.version = Tagen::VERSION
	s.summary = "a lightweight core and extra extensions for Ruby."
	s.description = <<-EOF
a lightweight core and extra extensions for Ruby. 
	EOF

	s.author = "Guten"
	s.email = "ywzhaifei@gmail.com"
	s.homepage = "http://github.com/GutenYe/tagen"
	s.rubyforge_project = "xx"

	s.files = `git ls-files`.split("\n")

  s.add_dependency "pd"
  s.add_dependency "activesupport", "~>3.2.0"
end
