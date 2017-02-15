require 'devise_enricher/version'
require 'devise'

module Devise # :nodoc:
  mattr_accessor :sqreen_enrich_token
  @sqreen_enrich_token = nil

  mattr_accessor :enrich_block_sign_in
  @enrich_block_sign_in = nil

  mattr_accessor :enrich_block_sign_up
  @enrich_block_sign_up = nil

  add_module :enrichable, :model => 'devise_enricher/model',
                          :insert_at => Devise::ALL.size
end

module DeviseEnricher
    class Engine < ::Rails::Engine
    end
end
