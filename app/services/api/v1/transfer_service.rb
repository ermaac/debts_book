module Api
  module V1
    class TransferService
      attr_reader :sender_email, :receiver_email, :transfer_amount,
                  :transfer_transaction

      def initialize(sender_email, receiver_email, transfer_amount)
        @sender_email = sender_email
        @receiver_email = receiver_email
        @transfer_amount = transfer_amount
      end

      def transfer
        @transfer_transaction = build_transfer_transaction
        return unless transfer_transaction.valid?
        TransactionTransfer.transaction(isolation: :repeatable_read) do
          set_balances
          sender_account.save!
          receiver_account.save!
          transfer_transaction.save!
        end
      end

      protected

      def build_transfer_transaction
        TransferTransaction.new(
          sender_account: sender_account,
          receiver_account: receiver_account,
          amount: transfer_amount
        )
      end

      def set_balances
        if sender_account.sufficient_balance?(withdrawal_amount: transfer_amount)
          sender_account.balance -= transfer_amount
          receiver_account.balance += transfer_amount
        else
          transfer_transaction.error = 'Insufficient balance'
        end
      end

      def sender
        @sender ||= UserService.new(sender_email).find_or_create_user
      end
      delegate :account, to: :sender, prefix: true

      def receiver
        @receiver ||= UserService.new(receiver_email).find_or_create_user
      end
      delegate :account, to: :receiver, prefix: true
    end
  end
end
