desc "build a gem file"
task :release do
	`rm *.gem &>/dev/null`
	sh "gem build tagen.gemspec"
	sh "gem push *.gem"
	sh "rm *.gem"
end

desc "install a gem"
task :install do
	`rm *.gem &>/dev/null`
	sh "gem build tagen.gemspec"
	sh "gem install *.gem"
	sh "rm *.gem"
end

desc "autotest with watchr"
task :test do
	sh "watchr tagen.watchr"
end

namespace :test do
	desc "testing the whole library"
	task :all do
		sh "rspec --color spec"
	end
end

def sh cmd
	puts cmd
	system cmd
end
