class UpdateRepoSubscriptionMultipleReadWrite < ActiveRecord::Migration
  def change
    add_column :repo_subscriptions, :write_limit, :integer
    add_column :repo_subscriptions, :read_limit,  :integer

    RepoSubscription.find_each do |sub|
      if sub.respond_to?(:write_limit)
        sub.write_limit = 3 if sub.write?
        sub.read_limit  = 3 if sub.read?
      end
    end
  end
end
