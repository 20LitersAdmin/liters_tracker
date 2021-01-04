# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  default template_path: 'reports/mailer'
  # layout false

  def first_report_of_month(report, user, opts={})
    @report = report
    @user   = user
    mail(to: @user.email, subject: "The First Report of #{Date::MONTHNAMES[@report.month]} #{@report.year}" )
  end
end
