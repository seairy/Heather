class CreateFares < ActiveRecord::Migration[5.0]
  def change
    create_table :fares do |t|
      t.references :currency, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.references :local_currency
      t.decimal :local_amount, precision: 10, scale: 2
      t.decimal :rate_of_exchange, precision: 10, scale: 2
      t.timestamps null: false
    end
  end
end
