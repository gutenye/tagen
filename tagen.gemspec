$: << File.expand_path('../lib', __FILE__)
require 'tagen/version'

Gem::Specification.new do |s|
	s.name = 'tagen'
	s.version = Tagen::VERSION
	s.summary = 'a core and extra extension to ruby library'
	s.description = <<-EOF
a core and extra extension to ruby library. 
	EOF

	s.author = 'Guten'
	s.email = 'ywzhaifei@gmail.com'
	s.homepage = 'http://github.com/GutenYe/tagen'
	s.rubyforge_project = 'xx'

	s.files = `git ls-files`.split('\n')

  s.add_dependency 'activesupport', '~>3.1.0'
end
