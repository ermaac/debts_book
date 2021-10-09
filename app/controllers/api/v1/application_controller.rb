module Api
  module V1
    class ApplicationController < ActionController::API
      rescue_from StandardError do |error|
        case error
        when ::ActiveRecord::RecordInvalid, TransferService::InsufficientBalanceError
          render_error(error, :unprocessable_entity)
        when ::ActiveRecord::RecordNotFound
          render_error(error, :not_found)
        else
          render_error(error, :internal_server_error)
        end
      end

      private

      def render_error(err, status_code)
        render(
          json: { error: err.message },
          status: status_code
        )
      end
    end
  end
end
