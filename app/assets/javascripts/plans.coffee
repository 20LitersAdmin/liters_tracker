# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['plans']) &&
    actionMatches(['new', 'edit', 'create', 'update'])

  # init datetimepicker
  dateMinStr = $('#plan_date.datetimepicker-input').attr('data-mindate')
  dateMaxStr = $('#plan_date.datetimepicker-input').attr('data-maxdate')
  dateMin = moment(dateMinStr, 'YYYY-MM-DD')
  dateMax = moment(dateMaxStr, 'YYYY-MM-DD')

  $('#plan_date.datetimepicker-input').datetimepicker({
    format: 'YYYY-MM-DD',
    useCurrent: false,
    minDate: dateMin,
    maxDate: dateMax,
    viewDate: dateMax,
    widgetPositioning: {
      horizontal: 'auto'
      vertical: 'bottom'
    }
  })

  $('#plan_district.plan-form').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))
    LinkedSelect.assessPolymorphics($(this))

  $('#plan_sector.plan-form').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))
    LinkedSelect.assessPolymorphics($(this))

  $('#plan_cell.plan-form').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))
    LinkedSelect.assessPolymorphics($(this))

  $('#plan_village.plan-form').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))
    LinkedSelect.assessPolymorphics($(this))

  $('#plan_facility.plan-form').on 'change', ->
    LinkedSelect.assessPolymorphics($(this))
