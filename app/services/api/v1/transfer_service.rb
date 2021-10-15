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
          [
            { id: sender_account.id, action: -> { sender_account.decrement!(:balance, transfer_amount) } },
            { id: receiver_account.id, action: -> { receiver_account.increment!(:balance, transfer_amount) } }
          ].sort_by { |e| e[:id] }.each { |e| e[:action].call }
        end
      rescue ActiveRecord::StatementInvalid => e
        if e.cause.is_a?(PG::CheckViolation) && e.message.match("balance_sufficiency_check")
          raise InsufficientBalanceError.new
        else
          raise e
        end
      end
    end
  end
end
