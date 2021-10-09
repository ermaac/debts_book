class Account < ApplicationRecord
  DEFAULT_BALANCE = 100

  belongs_to :user, required: true

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_defaults, unless: :persisted?

  def sufficient_balance?(withdrawal_amount:)
    balance >= withdrawal_amount
  end

  private

  def set_defaults
    self.balance = DEFAULT_BALANCE
  end
end
