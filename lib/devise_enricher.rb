require 'devise_enricher/version'
require 'devise'

module Devise # :nodoc:
  mattr_accessor :sqreen_enrich_token
  @sqreen_enrich_token = nil

  add_module :enrichable, :model => 'devise_enricher/model',
                          :insert_at => Devise::ALL.size
end
