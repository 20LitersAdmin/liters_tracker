# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['sectors']) &&
    actionMatches(['report'])

  dateStr = getParameterByName('date')
  date = moment(dateStr, 'YYYY-MM-DD')
  first = date.startOf('month').format('YYYY-MM-DD')
  last = date.endOf('month').format('YYYY-MM-DD')

  $('.datetimepicker-input').datetimepicker({
    format: 'YYYY-MM-DD'
    useCurrent: false
    viewDate: date.startOf('month')
    widgetPositioning: {
      horizontal: 'auto'
      vertical: 'bottom'
    }
  })

  $('.datetimepicker-input').datetimepicker('minDate', first)
  $('.datetimepicker-input').datetimepicker('maxDate', last)

  $('.datetimepicker-input').each( ()->
    if $(this).data('record') == 'existing'
      val = $(this).attr('value')
      $(this).datetimepicker('date', val)
  )

  # form error checking:
  $('div.warning-div').hide()

  # when distributed or checked is changed, make sure a date is provided
  $('tr.facility-row input.date-checker').on 'change', ->
    dataFinder = $(this).parents('tr.facility-row').attr('data-finder')
    reportDateFieldId = 'input#report_form_date_' + dataFinder
    reportDateField = $(reportDateFieldId)
    if Number($(this).val()) > 0
      if reportDateField.val() == ''
        reportDateField.css('border-color', '#dc3545')
        $('input[type=submit').attr('disabled', true)
        $('div.warning-div').show()
        $('div.submit-div').hide()
    else
      reportDateField.css('border-color', '')
      $('input[type=submit').attr('disabled', false)
      $('div.warning-div').hide()
      $('div.submit-div').show()
