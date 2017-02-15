require 'devise_enricher/enrich'
module Devise
  module Models
    # Add enrichment behavior to trackable
    module TrackableExtension
      def update_tracked_fields(request)
        return unless self.class.devise_modules.include?(:trackable)
        self.last_enriched_sign_in_ip = current_enriched_sign_in_ip
        self.current_enriched_sign_in_ip = enricher.enrich_ip(request.remote_ip)
        super(request)
      end
    end

    # Enrich model info using enrich
    module Enrichable
      extend ActiveSupport::Concern

      included do
        serialize :enriched_email
        serialize :current_enriched_sign_in_ip
        serialize :last_enriched_sign_in_ip
        before_save :enrich_email

        prepend TrackableExtension
      end

      def self.required_fields(klass)
        required_fields = %i(enriched_email)
        return required_fields unless klass.devise_modules.include?(:trackable)
        required_fields + %i(current_sign_in_ip last_sign_in_ip
                             current_enriched_sign_in_ip
                             last_enriched_sign_in_ip)
      end

      def enricher
        DeviseEnricher::Enrich.new(Devise.sqreen_enrich_token)
      end

      def enrich_email
        unless email.blank? || enriched_email.present?
          self.enriched_email = enricher.enrich_email(email)
        end
      end
    end
  end
end
