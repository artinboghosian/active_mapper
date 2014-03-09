# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_mapper/version'

Gem::Specification.new do |spec|
  spec.name          = "active_mapper"
  spec.version       = ActiveMapper::VERSION
  spec.authors       = ["Artin Boghosian"]
  spec.email         = ["artinboghosian@gmail.com"]
  spec.summary       = %q{Data mapper using ActiveRecord for data access}
  spec.description   = %q{Data mapper using ActiveRecord for data access}
  spec.homepage      = "https://github.com/artinboghosian/active_mapper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
end
