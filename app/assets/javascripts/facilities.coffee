# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['facilities', 'sectors']) &&
    actionMatches(['new', 'edit', 'create', 'update', 'report'])

  resetOptions = (target)->
    selectTarget = '#facility_' + target
    $(selectTarget).html('')
    $(selectTarget).append('<option></option>')
    if target == 'cell'
      $(selectTarget).append('<option disabled="disabled" value="0">Please select a sector</option>')
    else
      $(selectTarget).append('<option disabled="disabled" value="0">Please select a cell</option>')

  ajaxGeography = (recordType, recordId, resultType)->
    # recordType = [sector, cell]
    # recordId = int
    # resultType = [cell, village]
    uri = '/facilities/' + resultType + '_finder?' + recordType + '=' + recordId
    $.ajax(
      url: uri
    ).done (response) ->
      prepareOptions(resultType, response)

  appendOptionLoop = (record, target)->
    $(target).append('<option value="' + record.id + '">' + record.name + '</option>')

  prepareOptions = (target, records)->
    selectTarget = '#facility_' + target
    $(selectTarget).html('')
    $(selectTarget).append('<option></option>')
    appendOptionLoop(record, selectTarget) for record in records

  ## Geography lookups:
  # called from facilities#new, facilities#edit, or sectors#report

  # facilities#form sends a sector to facilities#cell_finder
  # facilities#form sends a cell or a sector to facilities#village_finder
  $('#facility_sector').on 'change', ->
    sectorId = $(this).val()
    resetOptions('village')
    if sectorId > 0 # sector select is blank
      ajaxGeography('sector', sectorId, 'cell')
    else
      resetOptions('cell')

  # facilities#modal_form sends a cell
  # called from sectors#report
  $('#facility_cell').on 'change', ->
    cellId = $(this).val()
    resetOptions('village')
    if cellId > 0
      ajaxGeography('cell', cellId, 'village')
