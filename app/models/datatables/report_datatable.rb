# frozen_string_literal: true

# require 'ajax_datatables_rails/datatable/datatable'

module Datatables
  class ReportDatatable < ApplicationDatatable

    def view_columns
      # Declare strings in this format: ModelName.column_name
      # or in aliased_join_table.column_name format
      @view_columns ||= {
        date:     { source: "Report.date", name: 'Date', searchable: true, cond: :like, orderable: true },
        location: { sources: { "Cell" => "name", "Facility" => "name", "Village" => "name" }, searchable: true, cond: :like, orderable: true },
        sector:   { searchable: false, orderable: false },
        tech:     { source: "Technology.short_name", searchable: true, cond: :like },
        dist:     { source: "Report.distributed", searchable: false, orderable: true },
        checked:  { source: "Report.checked", searchable: false, orderable: true },
        ppl:      { source: "Report.people", searchable: false, orderable: true },
        hrs:      { source: "Report.hours", searchable: false, orderable: true },
        impact:   { source: "Report.impact", searchable: false, orderable: true },
        author:   { source: "User.fname", searchable: true, cond: :like },
        actions:  { searchable: false, orderable: false }
    }.with_indifferent_access
    end

    def data
      records.map do |record|
        {
        date:     record.date,
        location: record.location,
        sector:   record.sector_name,
        tech:     record.technology.short_name,
        dist:     record.distributed,
        checked:  record.checked,
        ppl:      record.people,
        hrs:      record.hours,
        impact:   record.impact,
        author:   record.user.name,
        actions:  record.links,
        DT_RowId: record.id
        }
      end
    end

    def get_raw_records
      join_clause = %q(
        LEFT OUTER JOIN "cells"      ON "cells"."id"      = "reports"."reportable_id" AND "reports"."reportable_type" = 'Cell' 
        LEFT OUTER JOIN "facilities" ON "facilities"."id" = "reports"."reportable_id" AND "reports"."reportable_type" = 'Facility' 
        LEFT OUTER JOIN "villages"   ON "villages"."id"   = "reports"."reportable_id" AND "reports"."reportable_type" = 'Village'
      )

      Report.joins(join_clause)
            .includes(:technology, :user)
            .references(:technology, :user)
    end
  end
end
