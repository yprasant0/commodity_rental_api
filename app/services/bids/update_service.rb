module Bids
  class UpdateService < ApplicationService
    def initialize(bid, user, params)
      @bid = bid
      @user = user
      @params = params
    end

    def call
      Bid.transaction do
        @bid.with_lock do
          return ServiceResult.error("Cannot update non-active bid", :unprocessable_entity) unless @bid.active?
          return ServiceResult.error("Unauthorized to update this bid", :unauthorized) unless @bid.renter == @user

          if @bid.update(@params)
            ServiceResult.success(bid: @bid)
          else
            ServiceResult.error(@bid.errors.full_messages.join(", "), :unprocessable_entity)
          end
        end
      end
    rescue ActiveRecord::StaleObjectError
      ServiceResult.error("Concurrent update detected. Please refresh and try again.", :conflict)
    end
  end
end
