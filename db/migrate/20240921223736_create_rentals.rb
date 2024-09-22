class CreateRentals < ActiveRecord::Migration[7.0]
  def change
    create_table :rentals do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.decimal :monthly_price, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'active'
      t.references :commodity, null: false, foreign_key: true
      t.references :renter, null: false, foreign_key: { to_table: :users }
      t.integer :lock_version, default: 0, null: false

      t.timestamps
    end
  end
end
