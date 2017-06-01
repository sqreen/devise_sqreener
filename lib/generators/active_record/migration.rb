class DeviseSqreenerAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :sqreened_email, :text
    if <%= class_name %>.devise_modules.include?(:trackable)
      add_column :<%= table_name %>, :current_sqreened_sign_in_ip, :text
      add_column :<%= table_name %>, :last_sqreened_sign_in_ip, :text
    end
  end
end
