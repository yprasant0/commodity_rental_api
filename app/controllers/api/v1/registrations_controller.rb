# app/controllers/api/v1/registrations_controller.rb
module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json
      skip_before_action :authenticate_user!, only: [:create]

      def create
        build_resource(sign_up_params)
        resource.save
        Rails.logger.info "Resource saved: #{resource.persisted?}"
        if resource.persisted?
          if resource.active_for_authentication?
            render json: {
              status: "success",
              message: "User created successfully",
              payload: {
                user_id: resource.id,
                token: resource.generate_jwt
              }
            }, status: :created
          else
            render json: {
              status: "error",
              message: "User created but not authorized.",
              payload: {}
            }, status: :unauthorized
          end
        else
          render json: {
            status: "error",
            message: "User could not be created",
            payload: { errors: resource.errors.full_messages }
          }, status: :unprocessable_entity
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :role)
      end
    end
  end
end
