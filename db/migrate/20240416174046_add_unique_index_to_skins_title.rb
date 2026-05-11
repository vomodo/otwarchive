class AddUniqueIndexToSkinsTitle < ActiveRecord::Migration[6.1]
  #uses_departure! # disabled for self-hosted if Rails.env.staging? || Rails.env.production?

  def change
    remove_index :skins, :title
    add_index :skins, :title, unique: true
  end
end
