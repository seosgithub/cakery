# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dur/version'

Gem::Specification.new do |spec|
  spec.name          = "dur"
  spec.version       = Dur::VERSION
  spec.authors       = ["seo"]
  spec.email         = ["seotownsend@icloud.com"]
  spec.summary       = "A boring javascript application framework"
  spec.description   = "dur is a cross-platform application framework system that exports javascript files"
  spec.homepage      = "https://github.com/sotownsend/dur"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
end
