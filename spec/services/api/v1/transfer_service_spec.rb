require 'rails_helper'

describe Api::V1::TransferService do
  let(:sender_account) { build(:account, balance: sender_balance) }
  let!(:sender) { create(:user, account: sender_account) }
  let(:receiver_account) { build(:account) }
  let!(:receiver) { create(:user, account: receiver_account) }
  let(:transfer_amount) { 100 }

  let(:transfer_service) { described_class.new(sender_account, receiver_account, transfer_amount) }
  subject(:transfer) { transfer_service.transfer }

  describe '#transfer' do
    context 'when sender doesn\'t have sufficient balance' do
      let(:sender_balance) { transfer_amount - 1 }
      let(:transfer_txn) { transfer }
      let(:insufficient_balance_error) { Api::V1::TransferService::InsufficientBalanceError }

      it 'records TransferTransaction with error' do
        expect { transfer }.to raise_error(insufficient_balance_error)
        expect(TransferTransaction.last.error).to eq('Insufficient balance')
      end

      it 'doesn\'t change sender\'s balance' do
        expect { transfer }.to raise_error(insufficient_balance_error).and(not_change { sender_account.reload.balance })
      end

      it 'doesn\'t change receiver\'s balance' do
        expect { transfer }.to raise_error(insufficient_balance_error).and(not_change { receiver_account.reload.balance })
      end
    end

    context 'when receiver has sufficient balance' do
      let(:sender_balance) { transfer_amount }

      it 'withdaws transfer amount from sender account' do
        expect { transfer }.to change { sender_account.reload.balance }.by(-transfer_amount)
      end

      it 'deposits transfer amount to receiver account' do
        expect { transfer }.to change { receiver_account.reload.balance }.by(transfer_amount)
      end

      it 'records TransferTransaction without error' do
        transfer_txn = transfer
        expect(transfer_txn.error).to be_nil
      end
    end
  end
end
