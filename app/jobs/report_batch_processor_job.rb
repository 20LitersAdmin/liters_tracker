# frozen_string_literal: true

class ReportBatchProcessorJob < ApplicationJob
  queue_as :default

  def perform(batch_report_params, user_id)
    technology_id = batch_report_params[:technology_id].to_i
    contract_id = batch_report_params[:contract_id].to_i

    batch_report_params[:reports].each do |report_params|
      process(report_params, technology_id, contract_id, user_id)
    end
  end

  def process(report_params, technology_id, contract_id, user_id)
  end
end
