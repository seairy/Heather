class CreateMedicalExpenses < ActiveRecord::Migration[5.0]
  def change
    create_table :medical_expenses do |t|
      t.references :employee, null: false
      t.string :type_cd, null: false
      t.references :fare, null: false
      t.timestamps null: false
    end
  end
end
