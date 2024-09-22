require 'sidekiq/api'

class CloseBidWindowJob < ApplicationJob
  queue_as :default

  def perform(commodity_id)
    commodity = Commodity.find(commodity_id)
    CloseBidWindowService.call(commodity)
  end

  def self.scheduled?(commodity_id)
    job_id = "close_bid_window_#{commodity_id}"
    Sidekiq::ScheduledSet.new.any? { |job| job.args[0]['job_id'] == job_id }
  end
end
