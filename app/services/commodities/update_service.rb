module Commodities
  class UpdateService < ApplicationService
    def initialize(commodity, user, params)
      @commodity = commodity
      @user = user
      @params = params
    end

    def call
      return ServiceResult.error('Unauthorized') unless @commodity.lender == @user

      ActiveRecord::Base.transaction do
        @commodity.lock!
        if @commodity.update(@params)
          ServiceResult.success(commodity: @commodity)
        else
          raise ActiveRecord::RecordInvalid.new(@commodity)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.error(e.record.errors.full_messages)
    rescue ActiveRecord::StaleObjectError
      ServiceResult.error('The commodity has been updated. Please try again.')
    end
  end
end
