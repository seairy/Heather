class CreateCountryLevelPolicies < ActiveRecord::Migration
  def change
    create_table :country_level_policies do |t|
      t.references :country, null: false
      t.date :started_at, null: false
      t.date :ended_at, null: false
      t.integer :number, limit: 1, null: false
      t.timestamps null: false
    end
  end
end
