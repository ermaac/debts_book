class CreateTransferTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transfer_transactions do |t|
      t.references :sender_account, null: false, foreign_key: { to_table: :accounts }
      t.references :receiver_account, null: false, foreign_key: { to_table: :accounts }
      t.decimal :amount, null: false
      t.string :error

      t.timestamps
    end
  end
end
