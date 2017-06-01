module DeviseSqreener
  module Generators
    class DeviseSqreenerGenerator < Rails::Generators::NamedBase
      namespace "devise_sqreener"

      desc "Add :sqreenable directive in the given model. Also generate migration for ActiveRecord"

      def inject_devise_sqreenable_content
        path = File.join("app", "models", "#{file_path}.rb")
        inject_into_file(path, "sqreenable, :", :after => "devise :") if File.exists?(path)
      end

      hook_for :orm
    end
  end
end
