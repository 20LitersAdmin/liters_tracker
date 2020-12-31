class ReportMailerPreview < ActionMailer::Preview
  def first_monthly_report
    ReportMailer.first_report_of_month(Report.last, User.where(admin: true).first)
  end
end