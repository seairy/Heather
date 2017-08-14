class CreateServiceExceptions < ActiveRecord::Migration[5.0]
  def change
    create_table :service_exceptions do |t|
      t.references :administrator, null: false
      t.string :name, limit: 200, null: false
      t.text :message, :backtrace
      t.timestamps null: false
    end
  end
end
