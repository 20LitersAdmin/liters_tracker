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

  checkRow = (row) ->
    dist = row.find('input.distributed')
    check = row.find('input.checked')
    number = Number(dist.val()) + Number(check.val())
    date = row.find('input.datetimepicker-input')

    if number > 0 && date.val() == ''
      dist.css('border-color', '#dc3545')
      check.css('border-color', '#dc3545')
      date.css('border-color', '#dc3545')
      return 1
    else
      dist.css('border-color', '')
      check.css('border-color', '')
      date.css('border-color', '')
      return 0

  checkForm = () ->
    errorCount = 0
    $('tr.facility-row').each ()->
      errorCount += checkRow($(this))

    if errorCount > 0
      $('input[type=submit').attr('disabled', true)
      $('div.warning-div').show()
      $('div.submit-div').hide()
    else
      $('input[type=submit').attr('disabled', false)
      $('div.warning-div').hide()
      $('div.submit-div').show()

  $('tr.facility-row input.date-checker').on 'change', ->
    checkForm()

  $('input.datetimepicker-input').on 'change.datetimepicker', ({date, oldDate})  ->
    checkForm()
