class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.decimal :balance, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
