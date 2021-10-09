module Api
  module V1
    class TransferTransactionsController < ApplicationController
      def create
        sender, receiver = params.values_at(:from, :to).map { |email| UserService.new(email).find_or_create_user }
        TransferService.new(sender.account, receiver.account, params[:amount]).transfer
        render json: [sender.account, receiver.account]
      end
    end
  end
end
