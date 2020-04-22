# frozen_string_literal: true

class AddUserToStories < ActiveRecord::Migration[6.0]
  def change
    add_reference :stories, :user, index: true

    Story.update_all(user_id: 3)

    change_column_null :stories, :user_id, false
    add_foreign_key :stories, :users
  end
end
