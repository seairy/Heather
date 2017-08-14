class CreateWorkLocalCurrencies < ActiveRecord::Migration[5.0]
  def change
    create_table :work_local_currencies do |t|
      t.references :administrator, null: false
      t.references :currency, null: false
      t.timestamps null: false
    end
  end
end
