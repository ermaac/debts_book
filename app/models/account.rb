class Account < ApplicationRecord
  class InsufficientBalanceError < StandardError;
    def message
      'Insufficient balance'
    end
  end

  DEFAULT_BALANCE = 1000

  belongs_to :user, required: true

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_defaults, unless: :persisted?
  after_commit :notify_observers, on: :update

  def sufficient_balance?(withdrawal_amount:)
    balance >= withdrawal_amount
  end

  def withdraw!(amount)
    with_error_handling! do
      lock!
      self.balance -= amount
      save!
    end
  end

  def deposit!(amount)
    with_error_handling! do
      lock!
      self.balance += amount
      save!
    end
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

  def with_error_handling!
    yield
  rescue ActiveRecord::RecordInvalid
    raise InsufficientBalanceError.new if self.errors[:balance].present?
  rescue ActiveRecord::StatementInvalid => e
    if e.cause.is_a?(PG::CheckViolation) && e.message.match("balance_sufficiency_check")
      raise InsufficientBalanceError.new
    end
  end
end
