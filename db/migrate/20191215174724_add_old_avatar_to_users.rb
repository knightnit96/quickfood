class AddOldAvatarToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :old_avatar, :string
  end
end
