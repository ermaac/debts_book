class TransferTransaction < ApplicationRecord
  belongs_to :sender_account, class_name: 'Account', required: true
  belongs_to :receiver_account, class_name: 'Account', required: true

  validates_numericality_of :amount, greater_than: 0
  validate :validate_transfer_accounts_differ!

  def validate_transfer_accounts_differ!
    return unless sender_account_id == receiver_account_id

    errors.add(:base, 'Transfer accounts should be different')
  end
end
