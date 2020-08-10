# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['sectors', 'contracts']) &&
    actionMatches(['select'])

  updateButtonDates = (val) ->
    dateRegex = /\d{4}-\d{2}-\d{2}/
    notyearRegex = /-\d{2}-\d{2}/
    yearRegex = /\d{4}-/
    if val.length == 1
      val = '0' + val
    $('a[data-finder="tech-report-btn"]').each ->
      oldURI = $(this).attr('href')
      oldDate = oldURI.match(dateRegex)[0]
      if val.length == 4
        monthDayOnly = oldDate.match(notyearRegex)[0]
        newDate = val + monthDayOnly
      else
        yearOnly = oldDate.match(yearRegex)[0]
        newDate = yearOnly + val + '-01'
      newURI = oldURI.replace(dateRegex, newDate)
      $(this).attr('href', newURI)

  $('#date_month').on 'change', ->
    month_num = $(this).val()
    updateButtonDates(month_num)

  $('#date_year').on 'change', ->
    year_num = $(this).val()
    updateButtonDates(year_num)
