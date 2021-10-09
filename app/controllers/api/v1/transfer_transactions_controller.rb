module Api
  module V1
    class TransferTransactionsController < ApplicationController
      def create
        sender, receiver = params.values(:from, :to).map { |email| UserService.new(email).find_or_create_user }
        TransferService.new(@sender, @receiver, params[:amount]).transfer
      end
    end
  end
end
