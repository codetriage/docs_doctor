class AddWriteReadToRepoSubscriptions < ActiveRecord::Migration
  def change
    add_column :repo_subscriptions, :write, :boolean, :default => false
    add_column :repo_subscriptions, :read,  :boolean, :default => false
  end
end
