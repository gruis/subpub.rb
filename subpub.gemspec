require File.expand_path("../lib/subpub/version", __FILE__)
require "rubygems"

::Gem::Specification.new do |s|
  s.name                      = "subpub"
  s.version                   = Subpub::VERSION
  s.platform                  = ::Gem::Platform::RUBY
  s.authors                   = ["Caleb Crane"]
  s.email                     = ["subpub.rb@simulacre.org"]
  s.homepage                  = "http://www.simulacre.org/subpub.rb"
  s.summary                   = ""
  s.description               = ""
  s.required_rubygems_version = ">= 1.3.6"
  s.files                     = Dir["lib/**/*.rb", "bin/*", "*.md"]
  s.require_paths             = ['lib']
  s.executables               = Dir["bin/*"].map{|f| f.split("/")[-1] }
end
