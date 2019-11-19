# frozen_string_literal: true

require 'pathname'

# make a storage directory if it doesn't exist
Pathname(Constants::Story::IMAGE_DIR).mkpath
