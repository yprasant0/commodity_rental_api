module Commodities
  class DeleteService < ApplicationService
    def initialize(commodity, user)
      @commodity = commodity
      @user = user
    end

    def call
      return ServiceResult.error('Unauthorized') unless @commodity.lender == @user
      return ServiceResult.error('Cannot delete rented commodity') if @commodity.rented?

      ActiveRecord::Base.transaction do
        @commodity.lock!
        @commodity.destroy!
      end
      ServiceResult.success
    rescue ActiveRecord::RecordNotDestroyed => e
      ServiceResult.error(e.record.errors.full_messages)
    end
  end
end
