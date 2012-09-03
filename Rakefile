require "rbconfig"

PROJECT = "tagen"

sudo = Process.pid != 0 && RbConfig::CONFIG["host_os"] !~ /mswin|mingw/ ? "sudo" : ""

desc "build a gem file"
task :release do
	run "gem build tagen.gemspec"
	run "gem push *.gem"
  run "#{sudo} gem install *.gem"
	run "rm *.gem"
end

desc "install a gem file"
task :install do
	run "gem build tagen.gemspec"
	run "#{sudo} gem install *.gem"
	run "rm *.gem"
end

desc "run guard"
task :test do
	run "bundle exec guard -c -n f"
end

namespace :test do
  desc "testing the libraray"
	task :all do
		run "bundle exec rspec spec"
	end

  desc "Run all specs on multiple ruby versions (requires rvm)"
  task :portability do
    require "yaml"

    travis_config_file = File.expand_path("../.travis.yml", __FILE__)
    begin
      travis_options ||= YAML::load_file(travis_config_file)
    rescue => ex
      puts "Travis config file '#{travis_config_file}' could not be found: #{ex.message}"
      return
    end

    travis_options['rvm'].each do |version|
      system <<-BASH
bash -c 'source ~/.rvm/scripts/rvm;
rvm #{version};
ruby_version_string_size=`ruby -v | wc -m`
echo;
for ((c=1; c<$ruby_version_string_size; c++)); do echo -n "="; done
echo;
echo "`ruby -v`";
for ((c=1; c<$ruby_version_string_size; c++)); do echo -n "="; done
echo;
bundle install;
bundle exec rspec spec 2>&1;'
      BASH
    end
  end
end

desc "run yard server --reload"
task :doc do
	run "yard server --reload"
end

desc "clean up"
task :clean do
	run "rm *.gem"
end

desc "rewrite gemspec with add_dependency from Gemfile"
task :gemspec do
  require "bundler"
  gemspec = "#{PROJECT}.gemspec"

  deps = Bundler.definition.dependencies.find_all{|v|
    v.groups.include? :default
  }

  deps = deps.map {|dep|
    list = [dep.name] + dep.requirements_list
    "\ts.add_dependency #{list.map(&:inspect).join(', ')}\n"
  }

  lines = File.read(gemspec).lines.to_a
  idx = lines.find_index{|v| v =~ /s\.add_dependency/} || -2
  lines.delete_if{|v| v =~ /s\.add_dependency/}
  lines.insert(idx, *deps)

  File.write(gemspec, lines.join(""))
end

def run cmd
	puts cmd
	system cmd
end


