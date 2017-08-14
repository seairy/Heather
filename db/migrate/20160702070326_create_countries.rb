class CreateCountries < ActiveRecord::Migration[5.0]
  def change
    create_table :countries do |t|
      t.references :continent, null: false
      t.string :name, limit: 200, null: false
      t.timestamps null: false
    end
  end
end
