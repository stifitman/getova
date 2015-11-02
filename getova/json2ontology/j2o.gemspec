# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'j2o/version'

Gem::Specification.new do |spec|
  spec.name          = "j2o"
  spec.version       = J2o::VERSION
  spec.authors       = ["Benjamin Hiltpolt"]
  spec.email         = ["benjamin.hiltpolt@sti2.at"]
  spec.summary       = %q{This gem handles transformation between RDF formats using SPARQL Construcst}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

end
