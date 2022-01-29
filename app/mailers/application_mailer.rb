# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'track@20liters.org'
  layout 'mailer'
end
