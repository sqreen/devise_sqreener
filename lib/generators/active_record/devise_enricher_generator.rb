require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class DeviseEnricherGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../", __FILE__)

      def copy_devise_migration
        migration_template "migration.rb", "db/migrate/devise_enricher_add_to_#{table_name}.rb"
      end
    end
  end
end
