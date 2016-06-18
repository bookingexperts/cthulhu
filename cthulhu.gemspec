# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cthulhu/version'

Gem::Specification.new do |spec|
  spec.name          = "Cthulhu"
  spec.version       = Cthulhu::VERSION
  spec.authors       = ["behrooz shabani (everplays)\n"]
  spec.email         = ["everplays@gmail.com"]

  spec.summary       = %q{replacement for ActiveRecord dependent and Database's cascade}
  spec.description   = %q{If you do not want to setup foreign keys with cascade and ActiveRecord's dependent is too slow for your big database, this is what you are looking for.}
  spec.homepage      = "https://github.com/bookingexperts/cthulhu"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "schema_dev"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "factory_girl"
  spec.add_development_dependency "database_cleaner"

  spec.add_dependency "activerecord", "~> 4.2.6"
end
