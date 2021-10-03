class TransferTransaction < ApplicationRecord
  belongs_to :sender_account, class_name: 'Account', required: true
  belongs_to :receiver_account, class_name: 'Account', required: true
end
