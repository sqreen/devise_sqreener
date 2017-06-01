class AddUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      t.string :sqreened_email

      t.timestamps null: false
    end

    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
    create_table(:trackable_users) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.string :sqreened_email
      t.text :last_sqreened_sign_in_ip
      t.text :current_sqreened_sign_in_ip

      t.timestamps null: false
    end
  end
end

