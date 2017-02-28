class CreateRoomExpenses < ActiveRecord::Migration
  def change
    create_table :room_expenses do |t|
      t.references :employee, null: false
      t.date :started_at, null: false
      t.date :ended_at, null: false
      t.decimal :rent_yuan, precision: 7, scale: 2
      t.decimal :rent_dollar, precision: 7, scale: 2
      t.decimal :agency_fee_yuan, precision: 7, scale: 2
      t.decimal :agency_fee_dollar, precision: 7, scale: 2
      t.string :remarks, limit: 2000
      t.timestamps null: false
    end
  end
end
