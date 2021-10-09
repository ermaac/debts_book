class AccountsController < ApplicationController
  def index
    @accounts = Account.includes(:user).all
  end
end
