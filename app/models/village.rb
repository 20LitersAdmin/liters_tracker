# frozen_string_literal: true

class Village < ApplicationRecord
  include GeographyType
  include Rails.application.routes.url_helpers

  belongs_to :cell,       inverse_of: :villages

  has_one    :sector,     through: :cell,     inverse_of: :villages
  has_one    :district,   through: :sector,   inverse_of: :villages
  has_one    :country,    through: :district, inverse_of: :villages

  has_many   :facilities, inverse_of: :village, dependent: :destroy

  has_many   :reports,    as: :reportable, inverse_of: :reportable
  has_many   :plans,      as: :planable,   inverse_of: :planable

  validates_presence_of :name, :cell_id
  validates_uniqueness_of :gis_code, allow_blank: true

  after_save :update_hierarchy, if: -> { saved_change_to_cell_id? }

  def child_class
    'Facility'
  end

  def cells
    # Report and Plan want to be able to call any geography
    cell&.parent&.cells
  end

  def districts
    # Report and Plan want to be able to call any geography
    district&.parent&.districts
  end

  def facility
    # Report and Plan want to be able to call any geography
    nil
  end

  def parent
    cell
  end

  def pop_hh
    pop = population.present? ? ActiveSupport::NumberHelper.number_to_delimited(population, delimiter: ',') : '-'
    hh = households.present? ? ActiveSupport::NumberHelper.number_to_delimited(households, delimiter: ',') : '-'
    "#{pop} / #{hh}"
  end

  def related_plans
    Plan.where(planable_type: 'Village', planable_id: id)
        .or(Plan.where(planable_type: 'Facility', planable_id: facilities.pluck(:id)))
  end

  def related_reports
    Report.where(reportable_type: 'Village', reportable_id: id)
          .or(Report.where(reportable_type: 'Facility', reportable_id: facilities.pluck(:id)))
  end

  def related_stories
    Story.joins(:report).where("reports.reportable_type = 'Village' AND reports.reportable_id = ?", id)
         .or(Story.joins(:report).where("reports.reportable_type = 'Facility' AND reports.reportable_id IN (?)", facilities.pluck(:id)))
  end

  def sectors
    # Report and Plan want to be able to call any geography
    sectors&.parent&.sectors
  end

  def village
    self
  end

  def villages
    # Report and Plan want to be able to call any geography
    parent&.villages
  end

  def update_hierarchy(cascade: false)
    update_column(:hierarchy, cell.hierarchy << { parent_name: cell.name, parent_type: cell.class.to_s, link: cell_path(cell) })

    return unless cascade || saved_change_to_cell_id?

    reload.facilities.each do |f|
      f.reload.update_hierarchy
    end
  end
end
