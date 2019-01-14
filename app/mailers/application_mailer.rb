# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: '"20 Liters Tracker" track@20liters.org'
  layout 'mailer'
end
