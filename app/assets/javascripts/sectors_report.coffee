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
