class CreateRoomExpenses < ActiveRecord::Migration
  def change
    create_table :room_expenses do |t|
      t.references :employee, null: false
      t.date :started_at, null: false
      t.date :ended_at, null: false
      t.references :rent_fare, null: false
      t.references :agency_fare, null: false
      t.string :remarks, limit: 2000
      t.timestamps null: false
    end
  end
end
