class AddUserAdminRenamedAt < ActiveRecord::Migration[7.0]
  #uses_departure! # disabled for self-hosted if Rails.env.staging? || Rails.env.production?
  def change
    add_column :users, :admin_renamed_at, :datetime, null: true
  end
end
