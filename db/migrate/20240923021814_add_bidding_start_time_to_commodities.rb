class AddBiddingStartTimeToCommodities < ActiveRecord::Migration[7.0]
  def change
    add_column :commodities, :bidding_start_time, :datetime
  end
end
