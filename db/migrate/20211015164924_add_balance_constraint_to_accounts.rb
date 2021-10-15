class AddBalanceConstraintToAccounts < ActiveRecord::Migration[6.1]
  def up
    add_check_constraint :accounts, "balance >= 0", name: 'balance_check'
  end

  def down
    remove_check_constraint :accounts, name: 'balance_check'
  end
end
