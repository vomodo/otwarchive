class RemoveRecentlyResetFromUsers < ActiveRecord::Migration[7.1]
  #uses_departure! # disabled for self-hosted if Rails.env.staging? || Rails.env.production?

  def change
    remove_column :users, :recently_reset, :boolean
  end
end
