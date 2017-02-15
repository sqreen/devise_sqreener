class DeviseEnricherAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :enriched_email, :text
    if <%= class_name %>.devise_modules.include?(:trackable)
      add_column :<%= table_name %>, :current_enriched_sign_in_ip, :text
      add_column :<%= table_name %>, :last_enriched_sign_in_ip, :text
    end
  end
end
