class CreateCommodities < ActiveRecord::Migration[7.0]
  def change
    create_table :commodities do |t|
      t.string :name, null: false
      t.text :description
      t.string :category, null: false
      t.decimal :minimum_monthly_charge, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'available'
      t.string :bid_strategy, null: false
      t.references :lender, null: false, foreign_key: { to_table: :users }
      t.integer :lock_version, default: 0, null: false

      t.timestamps
    end
    add_index :commodities, :status
  end
end

