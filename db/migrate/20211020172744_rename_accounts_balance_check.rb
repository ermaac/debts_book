class RenameAccountsBalanceCheck < ActiveRecord::Migration[6.1]
  def up
    remove_check_constraint :accounts, name: 'balance_check'
    add_check_constraint :accounts, "balance >= 0", name: 'balance_sufficiency_check'
  end

  def down
    remove_check_constraint :accounts, name: 'balance_sufficiency_check'
    add_check_constraint :accounts, "balance >= 0", name: 'balance_check'
  end
end
