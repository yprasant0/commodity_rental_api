class CreateBids < ActiveRecord::Migration[7.0]
  def change
    create_table :bids do |t|
      t.decimal :monthly_price, precision: 10, scale: 2, null: false
      t.integer :lease_period, null: false
      t.string :status, null: false, default: 'active'
      t.references :commodity, null: false, foreign_key: true
      t.references :renter, null: false, foreign_key: { to_table: :users }
      t.integer :lock_version, default: 0, null: false

      t.timestamps
    end
    add_index :bids, [:commodity_id, :renter_id], unique: true, where: "status = 'active'"
  end
end
