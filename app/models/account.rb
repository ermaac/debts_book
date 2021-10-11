class Account < ApplicationRecord
  include CableReady::Broadcaster

  DEFAULT_BALANCE = 1000

  belongs_to :user, required: true

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_defaults, unless: :persisted?
  after_commit :notify_observers, on: :update

  def sufficient_balance?(withdrawal_amount:)
    balance >= withdrawal_amount
  end

  private

  def set_defaults
    self.balance = DEFAULT_BALANCE
  end

  def notify_observers
    remove_outdated_accounts_from_dom
    insert_updated_accounts_into_dom
    cable_ready.broadcast
  end

  def remove_outdated_accounts_from_dom
    cable_ready['accounts'].remove(
      selector: ".account[data-id=\"#{id}\"]",
      select_all: true
    )
  end

  def insert_updated_accounts_into_dom
    cable_ready['accounts'].insert_adjacent_html(
      selector: '#accounts',
      position: 'afterbegin',
      html: render(self)
    )
  end

  delegate :render, to: :ApplicationController
end
