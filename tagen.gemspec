Kernel.load File.expand_path("../lib/tagen/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = "tagen"
	s.version     = Tagen::VERSION
	s.summary     = "A lightweight core and extra extensions for Ruby."
	s.description = <<-EOF
A lightweight core and extra extensions for Ruby. Including some extensions from ActiveSupport.
	EOF

	s.author      = "Guten"
	s.email       = "ywzhaifei@gmail.com"
	s.homepage    = "http://github.com/GutenYe/tagen"

  s.files       = Dir["CHANGELOG.md", "README.md", "lib/**/*"]

  s.add_dependency "pd"
  s.add_dependency "activesupport"
end
