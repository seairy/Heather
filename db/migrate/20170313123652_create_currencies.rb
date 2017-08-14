class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :name, limit: 3, null: false
      t.string :description, limit: 100, null: false
      t.boolean :important, default: false, null: false
      t.timestamps null: false
    end
  end
end
