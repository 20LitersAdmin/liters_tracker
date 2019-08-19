# frozen_string_literal: true

class RemoveModelGid < ActiveRecord::Migration[6.0]
  def change
    remove_column(:plans, :model_gid)
    remove_column(:reports, :model_gid)
  end
end
