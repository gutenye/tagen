#!/usr/bin/rspec
require "bundler/setup"
require "guten/core/process"

ret = Process.daemon do
	p 1
end
p ret

