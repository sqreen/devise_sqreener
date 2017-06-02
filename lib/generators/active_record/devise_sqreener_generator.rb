require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class DeviseSqreenerGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../", __FILE__)

      def copy_devise_migration
        migration_template "migration.rb", "db/migrate/devise_sqreener_add_to_#{table_name}.rb", migration_version: migration_version
      end

      def migration_version
        if Rails::VERSION::MAJOR >= 5
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
      end
    end
  end
end
