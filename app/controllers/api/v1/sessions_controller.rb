module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json
      skip_before_action :authenticate_user!

      def create
        user = User.find_by_email(sign_in_params[:email])

        if user && user.valid_password?(sign_in_params[:password])
          token = user.generate_jwt
          render json: {
            status: "success",
            message: "User logged in successfully",
            payload: {
              user_id: user.id,
              token: token
            }
          }
        else
          render json: {
            status: "error",
            message: "Invalid email or password",
            payload: {}
          }, status: :unauthorized
        end
      end

      def destroy
        render json: {
          status: "success",
          message: "User logged out successfully",
          payload: {}
        }
      end

      private

      def sign_in_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
