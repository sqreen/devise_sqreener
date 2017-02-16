require 'devise_enricher/enrich'
module Devise
  module Models
    # Enrich model module, add all necessary behavior to a devise model
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

      # DB fields that are needed
      def self.required_fields(klass)
        required_fields = %i(enriched_email)
        return required_fields unless klass.devise_modules.include?(:trackable)
        required_fields + %i(current_sign_in_ip last_sign_in_ip
                             current_enriched_sign_in_ip
                             last_enriched_sign_in_ip)
      end

      # The current ip address lazily enriched
      def current_enriched_ip_address
        if current_ip_address.present?
          @current_enriched_ip ||= self.class.enricher.enrich_ip(current_ip_address)
        end
      end

      # The curren email address lazily enriched
      def current_enriched_email
        if email.present?
          @current_enriched_email ||= self.class.enricher.enrich_email(email)
        end
      end

      # Add enrichment behavior to trackable
      # Save last enriched_ip info
      def update_tracked_fields(request)
        return unless self.class.devise_modules.include?(:trackable)
        self.last_enriched_sign_in_ip = current_enriched_sign_in_ip
        self.current_enriched_sign_in_ip = current_enriched_ip_address
        super(request)
      end

      # Should the current sign in be blocked
      def enrich_block_sign_in?
        oracle = Devise.enrich_block_sign_in
        return false if oracle.blank? || !oracle.respond_to?(:call)
        oracle.call(current_enriched_email, current_enriched_ip_address, self)
      end

      # Should the current sign up be blocked
      # used as a on_create validation
      def enrich_block_sign_up?
        return false unless email_changed?
        oracle = Devise.enrich_block_sign_up
        return false if oracle.blank? || !oracle.respond_to?(:call)
        if oracle.call(current_enriched_email,
                       current_enriched_ip_address, self)
          errors[:base] = I18n.t(:forbidden, :scope => %i(devise registrations))
          return true
        end
        false
      end

      # When sign_in was refuse get the correct message
      def inactive_message
        enrich_block_sign_in? ? :forbidden : super
      end

      # save enriched email
      def enrich_email
        return if email.blank? || !email_changed?
        self.enriched_email = current_enriched_email
      end

      # Class methods
      module ClassMethods
        def enricher
          DeviseEnricher::Enrich.new(Devise.sqreen_enrich_token)
        end
      end
    end
  end
end

require 'devise_enricher/hook'
