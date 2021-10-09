FactoryBot.define do
  factory :transfer_transaction do
    sender_account { build(:account) }
    receiver_account { build(:account) }
    amount { 100 }
    error { nil }
  end
end
