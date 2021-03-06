class CreateTitleRanges < ActiveRecord::Migration[5.0]
  def change
    create_table :title_ranges do |t|
      t.references :employee, null: false
      t.string :type_cd, limit: 20, null: false
      t.date :started_at, null: false
      t.date :ended_at, null: false
      t.timestamps null: false
    end
  end
end
