class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :owner_email
      t.timestamps
    end

    add_column :editors, :account_id, :integer
    add_column :pages, :account_id, :integer

    add_index :editors, [:account_id, :email], :unique => true
    add_index :pages, [:account_id, :key], :unique => true
  end

  def self.down
    remove_column :editors, :account_id
    remove_column :pages, :account_id
    drop_table :accounts
  end
end
