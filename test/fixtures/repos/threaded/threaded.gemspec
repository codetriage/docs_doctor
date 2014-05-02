# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'threaded/version'

Gem::Specification.new do |gem|
  gem.name          = "threaded"
  gem.version       = Threaded::VERSION
  gem.authors       = ["Richard Schneeman"]
  gem.email         = ["richard.schneeman+rubygems@gmail.com"]
  gem.description   = %q{ Queue stuff in memory }
  gem.summary       = %q{ Memory, Enqueue stuff you will }
  gem.homepage      = "https://github.com/schneems/threaded"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake",  "~> 10.1"
  gem.add_development_dependency "mocha", "~>  1.0"
end
