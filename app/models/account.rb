class Account < ApplicationRecord
  DEFAULT_BALANCE = 1000

  belongs_to :user, required: true

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_defaults, unless: :persisted?
  after_commit :notify_observers, on: :update

  def sufficient_balance?(withdrawal_amount:)
    balance >= withdrawal_amount
  end

  def as_json(_)
    {
      email: user.email,
      balance: balance
    }
  end

  private

  def set_defaults
    self.balance = DEFAULT_BALANCE
  end

  def notify_observers
    AccountsBroadcastObserver.new(self).notify
  end
end
