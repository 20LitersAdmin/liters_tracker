# frozen_string_literal: true

class RemoveContractConstraintFromReport < ActiveRecord::Migration[6.0]
  def change
    change_column_null :reports, :contract_id, true
  end
end
