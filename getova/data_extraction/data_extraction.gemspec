# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'data_extraction/version'

Gem::Specification.new do |spec|
  spec.name          = "data_extraction"
  spec.version       = DataExtraction::VERSION
  spec.authors       = ["Benjamin Hiltpolt"]
  spec.email         = ["benjamin.hiltpolt@sti2.at"]
  spec.summary       = %q{This gem handles the data extraction for the GeToVa specific enabler}
  spec.description   = %q{This gem is used by the GeToVa Webinterface and the GeToVa REST API.
                          This gem can be run from the command line if desired"}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
