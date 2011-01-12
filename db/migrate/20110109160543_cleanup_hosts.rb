class CleanupHosts < ActiveRecord::Migration
  def self.up
    remove_column :editors, :host
    remove_column :pages, :host
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
