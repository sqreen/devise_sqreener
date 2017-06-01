# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devise_sqreener/version'

Gem::Specification.new do |spec|
  spec.name = 'devise_sqreener'

  spec.version     = DeviseSqreener::VERSION
  spec.summary     = 'Sqreen - Devise integration'
  spec.description = 'Sqreen emails/ips that are seen by Devise through the Sqreen API'
  spec.authors     = ['Sqreen']
  spec.email       = 'contact@sqreen.io'
  spec.homepage    = 'https://www.sqreen.io/'

  spec.files       = Dir['lib/**/*'] + %w(EADME.md Rakefile)
  spec.test_files  = []
  spec.require_paths = ['lib']
end
