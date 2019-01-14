$(document).on 'turbolinks:load', ->
  $('#datepicker_from').datetimepicker({
    format: 'YYYY-MM-DD'
  })
  $('#datepicker_to').datetimepicker({
    format: 'YYYY-MM-DD'
    useCurrent: false
  })

  # set initial values and max/min values
  fromVal = $('#datepicker_from').attr('value')
  $('#datepicker_from').datetimepicker('date', fromVal)

  earliest = $('#earliest').text()
  $('#datepicker_to').datetimepicker('minDate', earliest)
  $('#datepicker_from').datetimepicker('minDate', earliest)

  toVal = $('#datepicker_to').attr('value')
  $('#datepicker_to').datetimepicker('date', toVal)

  latest = $('#latest').text()
  $('#datepicker_from').datetimepicker('maxDate', latest)
  $('#datepicker_to').datetimepicker('maxDate', latest)


  # linked pickers
  $('#datepicker_from').on "change.datetimepicker", (e)->
    $('#datepicker_to').datetimepicker('minDate', e.date)
  $('#datepicker_to').on "change.datetimepicker", (e)->
    $('#datepicker_from').datetimepicker('maxDate', e.date)
