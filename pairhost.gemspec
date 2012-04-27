# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pairhost/version"

Gem::Specification.new do |s|
  s.name        = "pairhost"
  s.version     = Pairhost::VERSION
  s.authors     = ["Larry Karnowski"]
  s.email       = ["larry@hickorywind.org"]
  s.homepage    = "http://www.github.com/karnowski/pairhost"
  s.summary     = %q{Automate creation of Relevance-style pairhost EC2 instances.}
  s.description = %q{A Vagrant-like command line interface for creating, managing, and using EC2 instances for remote pairing like we do at Relevance.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_runtime_dependency "fog", "1.3.1"
  s.add_runtime_dependency "thor", "~> 0.15.2"
  s.add_runtime_dependency "hirb", "~> 0.6.2"

  s.add_development_dependency 'rspec', '~> 2.9.0'
  s.add_development_dependency 'bahia', '~> 0.7.2'
  s.add_development_dependency 'rake', '~> 0.9.2.2'
end
