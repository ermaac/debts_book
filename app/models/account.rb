class Account < ApplicationRecord
  belongs_to :user

  def sufficient_balance?(withdrawal_amount:)
    balance >= withdrawal_amount
  end
end
