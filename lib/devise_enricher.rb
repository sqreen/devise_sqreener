require 'devise_enricher/version'
require 'devise'

module Devise # :nodoc:
  # Token that will be used to call Sqreen Enrich
  mattr_accessor :sqreen_enrich_token
  @sqreen_enrich_token = nil

  # callable that will be used to authorize sign ins
  mattr_accessor :enrich_block_sign_in
  @enrich_block_sign_in = nil

  # callable that will be used to authorize sign ups
  mattr_accessor :enrich_block_sign_up
  @enrich_block_sign_up = nil

  add_module :enrichable, :model => 'devise_enricher/model',
                          :insert_at => Devise::ALL.size
end

module DeviseEnricher
  # Rails engine declaration (to pick up locales)
  class Engine < ::Rails::Engine
  end
end
