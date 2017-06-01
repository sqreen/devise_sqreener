require 'devise_sqreener/version'
require 'devise'

module Devise # :nodoc:
  # Token that will be used to call Sqreen API
  mattr_accessor :sqreen_api_token
  @sqreen_api_token = nil

  # callable that will be used to authorize sign ins
  mattr_accessor :sqreen_block_sign_in
  @sqreen_block_sign_in = nil

  # callable that will be used to authorize sign ups
  mattr_accessor :sqreen_block_sign_up
  @sqreen_block_sign_up = nil

  add_module :sqreenable, :model => 'devise_sqreener/model',
                          :insert_at => Devise::ALL.size
end

module DeviseSqreener
  # Rails engine declaration (to pick up locales)
  class Engine < ::Rails::Engine
  end
end
