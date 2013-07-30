# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_fu/version'

Gem::Specification.new do |spec|
  spec.name          = "acts_as_fu"
  spec.version       = ActsAsFu::VERSION
  spec.authors       = ["Pat Nakajima", "Alexander Simonov"]
  spec.email         = ["patnakajima@gmail.com", "alex@simonov.me"]
  spec.description   = %q{Generate ActiveRecord models on the fly for your tests}
  spec.summary       = %q{Generate ActiveRecord models on the fly for your tests}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '>= 3.2.13', '< 5'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
