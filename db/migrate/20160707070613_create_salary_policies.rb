class CreateSalaryPolicies < ActiveRecord::Migration[5.0]
  def change
    create_table :salary_policies do |t|
      t.string :type_cd, limit: 20, null: false
      t.date :started_at, null: false
      t.date :ended_at, null: false
      t.decimal :amount, precision: 7, scale: 2, null: false
      t.timestamps null: false
    end
  end
end
