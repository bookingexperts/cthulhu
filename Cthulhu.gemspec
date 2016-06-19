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

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|bin)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pg", '~> 0.18'
  spec.add_development_dependency "schema_dev", '~> 3.7'
  spec.add_development_dependency "pry", '~> 0.10'
  spec.add_development_dependency "factory_girl", '~> 4.7'
  spec.add_development_dependency "database_cleaner", '~> 1.5'

  spec.add_dependency "activerecord", "~> 4.2"
end
