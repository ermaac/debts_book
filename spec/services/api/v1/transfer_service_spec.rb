require 'rails_helper'

describe Api::V1::TransferService do
  let(:sender_account) { build(:account, balance: sender_balance) }
  let!(:sender) { create(:user, account: sender_account) }
  let(:receiver_account) { build(:account) }
  let!(:receiver) { create(:user, account: receiver_account) }
  let(:valid_balance) { 100 }
  let(:transfer_amount) { valid_balance }

  let(:transfer_service) { described_class.new(sender_account, receiver_account, transfer_amount) }
  subject(:transfer) { transfer_service.transfer }

  shared_examples 'sender\'s account balance not changed' do
    it 'doesn\'t change sender\'s balance' do
      expect { transfer }.to raise_error(error).and(not_change { sender_account.reload.balance })
    end
  end

  shared_examples 'receiver\'s account balance not changed' do
    it 'doesn\'t change receiver\'s balance' do
      expect { transfer }.to raise_error(error).and(not_change { receiver_account.reload.balance })
    end
  end

  describe '#transfer' do
    context 'with invalid params' do
      let(:sender_balance) { valid_balance }
      let(:error) { ActiveRecord::RecordInvalid }

      context 'when sender\'s account is blank' do
        let(:sender) { nil }
        let(:sender_account) { nil }
        include_examples 'receiver\'s account balance not changed'
      end

      context 'when receiver\'s account is blank' do
        let(:receiver) { nil }
        let(:receiver_account) { nil }
        include_examples 'sender\'s account balance not changed'
      end

      context 'when amount is blank' do
        let(:transfer_amount) { nil }
        include_examples 'sender\'s account balance not changed'
        include_examples 'receiver\'s account balance not changed'
      end

      context 'when amount is not a number' do
        let(:transfer_amount) { 'a' }
        include_examples 'sender\'s account balance not changed'
        include_examples 'receiver\'s account balance not changed'
      end

      context 'when amount is 0' do
        let(:transfer_amount) { 0 }
        include_examples 'sender\'s account balance not changed'
        include_examples 'receiver\'s account balance not changed'
      end

      context 'when sender\'s and receiver\'s account are the same' do
        let(:receiver_account) { sender_account }
        include_examples 'sender\'s account balance not changed'
        include_examples 'receiver\'s account balance not changed'
      end
    end

    context 'with valid params' do
      context 'when sender doesn\'t have sufficient balance' do
        let(:sender_balance) { valid_balance - 1 }
        let(:error) { Api::V1::TransferService::InsufficientBalanceError }

        it 'records TransferTransaction with error' do
          expect { transfer }.to raise_error(error)
          expect(TransferTransaction.last.error).to eq('Insufficient balance')
        end

        include_examples 'sender\'s account balance not changed'
        include_examples 'receiver\'s account balance not changed'
      end

      context 'when receiver has sufficient balance' do
        let(:sender_balance) { valid_balance }

        it 'withdraws transfer amount from sender account' do
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
end
