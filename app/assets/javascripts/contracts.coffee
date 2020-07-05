# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['contracts']) &&
    actionMatches(['new', 'edit'])

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
