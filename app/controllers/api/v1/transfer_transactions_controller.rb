module Api
  module V1
    class TransferTransactionsController < ApplicationController
      include CableReady::Broadcaster

      skip_before_action :verify_authenticity_token
      before_action :initialize_accounts!

      def create
        TransferService.new(@sender_account, @receiver_account, params[:amount]).transfer
        render json: [@sender_account, @receiver_account].map(&:reload)
      rescue Account::InsufficientBalanceError => e
        render_error(e, :unprocessable_entity)
      end

      private

      def initialize_accounts!
        @sender_account, @receiver_account = params.values_at(:from, :to).map do |email|
          user = UserService.new(email).find_or_create_user!
          user.account
        end
      end
    end
  end
end
