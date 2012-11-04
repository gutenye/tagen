#!/usr/bin/env ruby

dir = File.expand_path("../..", __FILE__)
$:.unshift File.join(dir, "lib")
ENV["BUNDLE_GEMFILE"] = File.join(dir, "Gemfile")

#require "bundler/setup"
require "benchmark"

Benchmark.bm do |b|
  b.report('require "tagen/some"'){ require "tagen/core/io"; require "tagen/core/array" }
  #b.report('require "tagen/core"') { require "tagen/core" }
end
