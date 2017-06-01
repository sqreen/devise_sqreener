require 'devise_sqreener/sqreen'
module Devise
  module Models
    # Sqreen model module, add all necessary behavior to a devise model
    module Sqreenable
      extend ActiveSupport::Concern

      included do
        serialize :sqreened_email
        serialize :current_sqreened_sign_in_ip
        serialize :last_sqreened_sign_in_ip
        before_save :sqreen_email

        validate :sqreen_block_sign_up?, :on => :create

        attr_accessor :current_ip_address
      end

      # DB fields that are needed
      def self.required_fields(klass)
        required_fields = %i(sqreened_email)
        return required_fields unless klass.devise_modules.include?(:trackable)
        required_fields + %i(current_sign_in_ip last_sign_in_ip
                             current_sqreened_sign_in_ip
                             last_sqreened_sign_in_ip)
      end

      # The current ip address lazily sqreened
      def current_sqreened_ip_address
        if current_ip_address.present?
          @current_sqreened_ip ||= self.class.sqreener.sqreen_ip(current_ip_address)
        end
      end

      # The curren email address lazily sqreened
      def current_sqreened_email
        if email.present?
          @current_sqreened_email ||= self.class.sqreener.sqreen_email(email)
        end
      end

      # Add sqreening behavior to trackable
      # Save last sqreened_ip info
      def update_tracked_fields(request)
        return unless self.class.devise_modules.include?(:trackable)
        self.last_sqreened_sign_in_ip = current_sqreened_sign_in_ip
        self.current_sqreened_sign_in_ip = current_sqreened_ip_address
        super(request)
      end

      # Should the current sign in be blocked
      def sqreen_block_sign_in?
        oracle = Devise.sqreen_block_sign_in
        return false if oracle.blank? || !oracle.respond_to?(:call)
        oracle.call(current_sqreened_email, current_sqreened_ip_address, self)
      end

      # Should the current sign up be blocked
      # used as a on_create validation
      def sqreen_block_sign_up?
        return false unless email_changed?
        oracle = Devise.sqreen_block_sign_up
        return false if oracle.blank? || !oracle.respond_to?(:call)
        if oracle.call(current_sqreened_email,
                       current_sqreened_ip_address, self)
          errors[:base] = I18n.t(:forbidden, :scope => %i(devise registrations))
          return true
        end
        false
      end

      # When sign_in was refuse get the correct message
      def inactive_message
        sqreen_block_sign_in? ? :forbidden : super
      end

      # save sqreened email
      def sqreen_email
        return if email.blank? || !email_changed?
        self.sqreened_email = current_sqreened_email
      end

      # Class methods
      module ClassMethods
        def sqreener
          DeviseSqreener::Sqreen.new(Devise.sqreen_api_token)
        end
      end
    end
  end
end

require 'devise_sqreener/hook'
