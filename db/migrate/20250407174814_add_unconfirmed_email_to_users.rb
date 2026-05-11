class AddUnconfirmedEmailToUsers < ActiveRecord::Migration[7.1]
  #uses_departure! # disabled for self-hosted if Rails.env.staging? || Rails.env.production?

  def change
    add_column :users, :unconfirmed_email, :string
  end
end
