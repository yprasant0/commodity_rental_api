module Commodities
  class RelistService < ApplicationService
    def initialize(commodity, user, params)
      @commodity = commodity
      @user = user
      @params = params
    end

    def call
      return ServiceResult.error('Unauthorized') unless @commodity.lender == @user
      return ServiceResult.error('Cannot relist rented commodity') if @commodity.rented?

      ActiveRecord::Base.transaction do
        @commodity.lock!
        @commodity.assign_attributes(@params)
        @commodity.start_bidding!
        @commodity.save!
      end
      ServiceResult.success(commodity: @commodity)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.error(e.record.errors.full_messages)
    rescue AASM::InvalidTransition => e
      ServiceResult.error("Invalid state transition: #{e.message}")
    end
  end
end
