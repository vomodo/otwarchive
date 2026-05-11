class ChangeBookmarksIdType < ActiveRecord::Migration[7.1]
  #uses_departure! # disabled for self-hosted if Rails.env.staging? || Rails.env.production?

  def up
    change_column :bookmarks, :id, "bigint NOT NULL AUTO_INCREMENT"
  end

  def down
  end
end
