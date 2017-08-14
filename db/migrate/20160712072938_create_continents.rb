class CreateContinents < ActiveRecord::Migration[5.0]
  def change
    create_table :continents do |t|
      t.string :name, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
