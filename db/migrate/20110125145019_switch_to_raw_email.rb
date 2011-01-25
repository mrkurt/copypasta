class SwitchToRawEmail < ActiveRecord::Migration
  def self.up
    drop_table :emails

    create_table :emails do |t|
      t.binary :raw
      t.string :digest
      t.string :type
    end

    add_index :emails, :digest, :unique => true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
