# frozen_string_literal: true

class AddNameToContract < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts, :name, :string

    Contract.all.each do |cont|
      cont.update(name: "#{cont.id}: #{cont.start_date.strftime('%m/%Y')} - #{cont.end_date.strftime('%m/%Y')}")
    end
  end

  def down
    remove_column :contracts, :name
  end
end
