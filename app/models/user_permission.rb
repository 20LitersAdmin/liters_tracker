# frozen_string_literal: true

class UserPermission < ApplicationRecord
  serialize :model_gid
end
