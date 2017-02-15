require 'devise_enricher/version'
require 'devise'

Devise.add_module :enrichable, :model => "devise_enricher/model"
