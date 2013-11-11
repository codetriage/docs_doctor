class AddExcludedToRepo < ActiveRecord::Migration
  def change
    add_column :repos, :excluded, :string
  end
end
