$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "birja_kreditov/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "birja_kreditov_api"
  s.version     = BirjaKreditov::VERSION
  s.authors     = ["sigra"]
  s.email       = ["sigra.yandex@gmail.com"]
  s.homepage    = ""
  s.summary     = "Ruby wrapper for BirjaKreditov.com"
  s.description = "Dictionaries, parsing xml, make requests, parse responses"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'rails', '~> 4.0.8'
  s.add_dependency 'nokogiri'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.0'
  # s.add_development_dependency 'mechanize'
  # s.add_development_dependency 'guard-rspec'

  s.add_development_dependency 'awesome_print'
end
