class CreateTravelExpenses < ActiveRecord::Migration
  def change
    create_table :travel_expenses do |t|
      t.references :employee, null: false
      t.string :role_cd, limit: 20, null: false
      t.string :type_cd, limit: 20, null: false
      t.date :departured_at, null: false
      t.decimal :departure_flight_fare_yuan, precision: 7, scale: 2
      t.decimal :departure_flight_fare_dollar, precision: 7, scale: 2
      t.date :returned_at, null: false
      t.decimal :return_flight_fare_yuan, precision: 7, scale: 2
      t.decimal :return_flight_fare_dollar, precision: 7, scale: 2
      t.string :remarks, limit: 2000
      t.timestamps null: false
    end
  end
end
