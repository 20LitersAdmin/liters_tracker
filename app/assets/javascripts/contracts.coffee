# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['contracts']) &&
    actionMatches(['new', 'edit', 'show', 'plan'])

  # init datetimepickers
  $('.datetimepicker-input').datetimepicker({
    format: 'YYYY-MM-DD',
    useCurrent: false,
    widgetPositioning: {
      horizontal: 'auto'
      vertical: 'bottom'
    }
  })

  startDate = $('#contract_start_date').attr('value')
  $('#contract_start_date').datetimepicker('date', startDate)

  endDate = $('#contract_end_date').attr('value')
  $('#contract_end_date').datetimepicker('date', endDate)

  # plans table on Contracts#show
  $('table#plans-dttb').dataTable
    processing: true
    ajax:
      url: $('table#plans-dttb').data('source')
    lengthMenu: [[50, 100, 500, -1], [50, 100, 500, "All"] ]
    columns: [
      {data: 'technology'}
      {data: 'location'}
      {data: 'date'}
      {data: 'goal'}
      {data: 'people'}
      {data: 'links'}
    ]
    pagingType: 'full_numbers'
    language: {
      paginate: {
        first: "&#8676",
        previous: "&#8592",
        next: "&#8594",
        last: "&#8677"
      }
    }
