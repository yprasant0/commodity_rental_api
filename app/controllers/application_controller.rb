# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json

  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActiveRecord::StaleObjectError, with: :conflict
  rescue_from AASM::InvalidTransition, with: :invalid_transition

  private

  def authenticate_user!
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, Rails.application.credentials.secret_key_base).first
      @current_user_id = jwt_payload['id']
    end

    render json: { status: 'error', message: 'Not Authorized', payload: {} }, status: 401 unless current_user
  rescue JWT::DecodeError
    render json: { status: 'error', message: 'Invalid token', payload: {} }, status: 401
  end

  def current_user
    @current_user ||= User.find(@current_user_id)
  end

  def not_found
    render json: { error: 'Resource not found' }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def conflict
    render json: { error: 'The resource has been modified. Please try again.' }, status: :conflict
  end

  def invalid_transition(exception)
    render json: { error: "Invalid state transition: #{exception.message}" }, status: :unprocessable_entity
  end
end
