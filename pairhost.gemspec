# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pairhost/version"

Gem::Specification.new do |s|
  s.name        = "pairhost"
  s.version     = Pairhost::VERSION
  s.authors     = ["Larry Karnowski"]
  s.email       = ["larry@hickorywind.org"]
  s.homepage    = "http://www.github.com/karnowski/pairhost"
  s.summary     = %q{Automate creation of Relevance pairhost EC2 instances.}
  s.description = %q{A Vagrant-like command line interface for creating, managing, and using EC2 instances for remote pairing.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_runtime_dependency "fog", "1.1.2"
  s.add_runtime_dependency "thor", "0.14.6"
end
