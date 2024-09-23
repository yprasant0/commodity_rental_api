module Commodities
  class CreateService < ApplicationService
    def initialize(user, params)
      @user = user
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        commodity = @user.commodities.new(@params)

        if commodity.save
          commodity.start_bidding!
          ServiceResult.success(format_commodity(commodity))
        else
          ServiceResult.error(commodity.errors.full_messages.join(", "))
          raise ActiveRecord::Rollback
        end
      end
    rescue StandardError => e
      ServiceResult.error("Failed to create commodity: #{e.message}")
    end

    private

    def format_commodity(commodity)
      {
        commodity_id: commodity.id,
        quote_price_per_month: commodity.minimum_monthly_charge,
        created_at: commodity.created_at
      }
    end
  end
end
