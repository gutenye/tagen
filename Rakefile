desc "build a gem file"
task :release do
	`rm *.gem &>/dev/null`
	sh "gem build tagen.gemspec"
	sh "gem push *.gem"
	sh "rm *.gem"
end

desc "testing the library"
task :test do
	sh "watchr tagen.watchr"
end

def sh cmd
	puts cmd
	system cmd
end
