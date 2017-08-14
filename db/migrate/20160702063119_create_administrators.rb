class CreateAdministrators < ActiveRecord::Migration
  def change
    create_table :administrators do |t|
      t.string :account, limit: 16, null: false
      t.string :hashed_password, limit: 100, null: false
      t.string :name, limit: 100, null: false
      t.references :last_used_currency
      t.references :last_used_local_currency
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
