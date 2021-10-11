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
        @transfer_amount = transfer_amount&.to_i
      end

      def transfer
        @transfer_transaction = build_transfer_transaction
        transfer_transaction.validate!

        begin
          update_balances!
        rescue InsufficientBalanceError => e
          transfer_transaction.error = e.message
          raise e
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
        ActiveRecord::Base.transaction do
          raise InsufficientBalanceError unless sender_account.sufficient_balance?(withdrawal_amount: transfer_amount)

          sender_account.reload.lock!('for update nowait').update!(balance:  sender_account.balance - transfer_amount)
          receiver_account.reload.lock!('for update nowait').update!(balance: receiver_account.balance + transfer_amount)
        end
      rescue StandardError => e
        unless e.is_a?(InsufficientBalanceError)
          sleep(rand/50)
          retry
        else raise e
        end
      end
    end
  end
end
