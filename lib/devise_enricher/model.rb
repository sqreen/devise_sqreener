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
        unless email.blank?
          self.enriched_email = DeviseEnricher.enrich_email(email)
        end
      end
    end
  end
end
