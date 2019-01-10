# frozen_string_literal: true

json.array! @updates, partial: 'updates/update', as: :update
