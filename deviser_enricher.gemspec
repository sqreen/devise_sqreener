# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devise_enricher/version'

Gem::Specification.new do |spec|
  spec.name = 'devise_enricher'

  spec.version     = DeviseEnricher::VERSION
  spec.summary     = 'Sqreen Enrich - Devise integration'
  spec.description = 'Enrich emails/ips that are seen by devise through Sqreen Enrich'
  spec.authors     = ['Sqreen']
  spec.email       = 'contact@sqreen.io'
  spec.homepage    = 'https://www.sqreen.io/'

  spec.files       = Dir['lib/**/*'] + %w(EADME.md Rakefile)
  spec.test_files  = []
  spec.require_paths = ['lib']
end
