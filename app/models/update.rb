# frozen_string_literal: true

class Update < ApplicationRecord
  belongs_to :technology, inverse_of: :updates
  belongs_to :user,       inverse_of: :updates
  serialize :model_gid
end
