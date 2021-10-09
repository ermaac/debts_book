module Api
  module V1
    class TransferService
      class InsufficientBalanceError < StandardError;
        def message
          'Insufficient balance'
        end
      end

      attr_reader :sender_account, :receiver_account, :transfer_amount,
                  :transfer_transaction

      def initialize(sender_account, receiver_account, transfer_amount)
        @sender_account = sender_account
        @receiver_account = receiver_account
        @transfer_amount = transfer_amount
      end

      def transfer
        @transfer_transaction = build_transfer_transaction
        return unless transfer_transaction.valid?

        begin
          update_balances!
        rescue InsufficientBalanceError => e
          transfer_transaction.error = e.message
        ensure
          transfer_transaction.save!
        end
        transfer_transaction
      end

      protected

      def build_transfer_transaction
        TransferTransaction.new(
          sender_account: sender_account,
          receiver_account: receiver_account,
          amount: transfer_amount
        )
      end

      def update_balances!
        ActiveRecord::Base.transaction(isolation: :repeatable_read) do
          raise InsufficientBalanceError unless sender_account.sufficient_balance?(withdrawal_amount: transfer_amount)

          sender_account.update!(balance:  sender_account.balance - transfer_amount)
          receiver_account.update!(balance: receiver_account.balance + transfer_amount)
        end
      rescue ActiveRecord::StatementInvalid => e
        sleep(rand / 100)
        retry
      end
    end
  end
end
