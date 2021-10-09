module Api
  module V1
    class TransferTransactionsController < ApplicationController
      def create
        TransferService.new(params.values_at(:from, :to, :amount)).transfer
      end
    end
  end
end
