require 'sidekiq/api'

class CloseBidWindowJob < ApplicationJob
  queue_as :default

  def perform(commodity_id)
    commodity = Commodity.find(commodity_id)
    CloseBidWindowService.call(commodity)
  end

  def self.schedule(commodity)
    set(wait: 3.hours).perform_later(commodity.id)
  end
end




