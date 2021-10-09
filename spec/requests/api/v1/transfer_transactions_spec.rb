require 'rails_helper'

RSpec.describe "Api::V1::TransferTransactions", type: :request do
  describe "POST /create" do
    xit "returns http success" do
      post "/api/v1/transfer_transactions/create"
      expect(response).to have_http_status(:success)
    end
  end
end
