require 'rails_helper'

RSpec.describe "Api::V1::TransferTransactions", type: :request do
  describe "POST /create" do
    let(:params) { { from: 'sender@gmail.com', to: 'receiver@gmail.com' } }
    context 'with invalid params' do
      let(:invalid_params) { params.merge(amount: 0) }

      it 'returns unprocessable entity status' do
        post '/api/v1/transfer', params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with valid params' do
      let(:valid_params) do
        { from: 'sender@gmail.com', to: 'receiver@gmail.com', amount: 100 }
      end

      it 'returns http success' do
        post '/api/v1/transfer', params: valid_params
        expect(response).to have_http_status(:success)
      end
    end
  end
end
