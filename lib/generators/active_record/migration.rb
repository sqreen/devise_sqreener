class DeviseEnricherAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :enriched_email, :text
  end
end
