module Commodities
  class CreateService < ApplicationService
    def initialize(user, params)
      @user = user
      @params = params
    end

    def call
      commodity = nil
      ActiveRecord::Base.transaction do
        commodity = @user.commodities.new(@params)
        commodity.save!
        commodity.start_bidding!
      end
      ServiceResult.success(commodity: commodity)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.error(e.record.errors.full_messages)
    end
  end
end
