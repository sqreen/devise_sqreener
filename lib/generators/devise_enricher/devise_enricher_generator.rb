module DeviseEnricher
  module Generators
    class DeviseEnricherGenerator < Rails::Generators::NamedBase
      namespace "devise_enricher"

      desc "Add :enrichable directive in the given model. Also generate migration for ActiveRecord"

      def inject_devise_enrichable_content
        path = File.join("app", "models", "#{file_path}.rb")
        inject_into_file(path, "enrichable, :", :after => "devise :") if File.exists?(path)
      end

      hook_for :orm
    end
  end
end
