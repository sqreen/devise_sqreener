require 'devise_enricher/enrich'
module Devise
  module Models
    # Enrich model info using enrich
    module Enrichable
      extend ActiveSupport::Concern

      included do
        serialize :enriched_email
        serialize :current_enriched_sign_in_ip
        serialize :last_enriched_sign_in_ip
        before_save :enrich_email

        validate :enrich_block_sign_up?, :on => :create

        attr_accessor :current_ip_address
      end

      def self.required_fields(klass)
        required_fields = %i(enriched_email)
        return required_fields unless klass.devise_modules.include?(:trackable)
        required_fields + %i(current_sign_in_ip last_sign_in_ip
                             current_enriched_sign_in_ip
                             last_enriched_sign_in_ip)
      end

      def current_enriched_ip_address
        if current_ip_address.present?
          @current_enriched_ip ||= enricher.enrich_ip(current_ip_address)
        end
      end

      def current_enriched_email
        if email.present?
          @current_enriched_email ||= enricher.enrich_email(email)
        end
      end

      # Add enrichment behavior to trackable
      def update_tracked_fields(request)
        return unless self.class.devise_modules.include?(:trackable)
        self.last_enriched_sign_in_ip = current_enriched_sign_in_ip
        self.current_enriched_sign_in_ip = current_enriched_ip_address
        super(request)
      end

      def enrich_block_sign_in?
        oracle = Devise.enrich_block_sign_in
        return false if oracle.blank? || !oracle.respond_to?(:call)
        oracle.call(current_enriched_email, current_enriched_ip_address, self)
      end

      def enrich_block_sign_up?
        return unless email_changed?
        oracle = Devise.enrich_block_sign_up
        return false if oracle.blank? || !oracle.respond_to?(:call)
        if oracle.call(current_enriched_email,
                       current_enriched_ip_address, self)
          errors[:base] = I18n.t(:forbidden, :scope => %i(devise registrations))
        end
      end

      def inactive_message
        enrich_block_sign_in? ? :forbidden : super
      end

      def enricher
        DeviseEnricher::Enrich.new(Devise.sqreen_enrich_token)
      end

      def enrich_email
        return if email.blank? || !email_changed?
        self.enriched_email = current_enriched_email
      end
    end
  end
end

require 'devise_enricher/hook'
