class ChangeStoryTextToText < ActiveRecord::Migration[6.0]
  def change
    change_column :stories, :text, :text
  end
end
