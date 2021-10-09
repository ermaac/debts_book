class User < ApplicationRecord
  EMAIL_REGEXP = /\A[^@\s]+@[^@\s]+\z/
  has_one :account, required: true

  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_REGEXP }
end
