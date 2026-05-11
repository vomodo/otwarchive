class RemoveEmailVisibleAndDateOfBirthVisibleFromPreferences < ActiveRecord::Migration[7.1]
  #uses_departure! # disabled for self-hosted if Rails.env.staging? || Rails.env.production?
   
  def change
    remove_column :preferences, :email_visible, :boolean
    remove_column :preferences, :date_of_birth_visible, :boolean
  end
end
