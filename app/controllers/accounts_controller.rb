class AccountsController < ApplicationController
  def index
    @accounts = Account.includes(:user).all.order(updated_at: :desc)
  end
end
