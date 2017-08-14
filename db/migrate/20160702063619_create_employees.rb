class CreateEmployees < ActiveRecord::Migration[5.0]
  def change
    create_table :employees do |t|
      t.string :name, limit: 200, null: false
      t.references :country, null: false
      t.string :type_cd, null: false
      t.string :domestic_organization, limit: 1000, null: false
      t.string :foreign_organization, limit: 1000, null: false
      t.date :departured_at, null: false
      t.date :returned_at, null: false
      t.decimal :subsidy, precision: 7, scale: 2, null: false
      t.decimal :household_allowance, precision: 7, scale: 2, null: false
      t.decimal :teaching_material_subsidy, precision: 7, scale: 2, null: false
      t.decimal :delay_subsidy, precision: 7, scale: 2, null: false
      t.decimal :rate_of_exchange, precision: 7, scale: 2
      t.timestamps null: false
    end
  end
end
