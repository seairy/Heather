class CreateTravelSubsidyPolicies < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_subsidy_policies do |t|
      t.integer :level, limit: 1, null: false
      t.date :started_at, null: false
      t.date :ended_at, null: false
      t.decimal :amount, precision: 7, scale: 2, null: false
      t.timestamps null: false
    end
  end
end
