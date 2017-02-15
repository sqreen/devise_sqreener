require 'devise_enricher/enrich'
module Devise
  module Models
    # Enrich model info using enrich
    module Enrichable
      extend ActiveSupport::Concern

      included do
        serialize :enriched_email
        before_save :enrich_email
      end

      def enrich_email
        unless email.blank? || enriched_email.present?
          enricher = DeviseEnricher::Enrich.new(Devise.sqreen_enrich_token)
          self.enriched_email = enricher.enrich_email(email)
        end
      end
    end
  end
end
