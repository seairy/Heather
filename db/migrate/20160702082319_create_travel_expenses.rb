class CreateTravelExpenses < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_expenses do |t|
      t.references :employee, null: false
      t.string :role_cd, limit: 20, null: false
      t.string :type_cd, limit: 20, null: false
      t.date :departured_at, null: false
      t.references :departure_flight_fare, null: false
      t.date :returned_at, null: false
      t.references :return_flight_fare, null: false
      t.string :remarks, limit: 2000
      t.timestamps null: false
    end
  end
end
