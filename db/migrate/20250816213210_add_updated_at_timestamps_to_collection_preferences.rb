class AddUpdatedAtTimestampsToCollectionPreferences < ActiveRecord::Migration[7.1]
  #uses_departure! # disabled for self-hosted if Rails.env.staging? || Rails.env.production?

  def change
    add_column :collection_preferences, :unrevealed_updated_at, :datetime, default: nil
    add_column :collection_preferences, :anonymous_updated_at, :datetime, default: nil
  end
end
