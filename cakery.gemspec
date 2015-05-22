# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cakery/version'

Gem::Specification.new do |spec|
  spec.name          = "cakery"
  spec.version       = Cakery::VERSION
  spec.authors       = ["seo"]
  spec.email         = ["seotownsend@icloud.com"]
  spec.summary       = "Combine many files into one intelligently"
  spec.description   = "Combine many files into one intelligently.  Cakery has a simple *DSL* that allows you to glob directories and pass strings to an **erb** file.  You can also add **macros** to a cakery pipeline. Think about it as a more generic version of [Sprockets](https://github.com/sstephenson/sprockets)."
  spec.homepage      = "https://github.com/sotownsend/cakery"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry", "~> 0.10"
end
