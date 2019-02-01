# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['facilities']) &&
    actionMatches(['new', 'edit', 'create', 'update'])

  appendOption = (record)->
    $('#facility_village_id').append('<option value="' + record.id + '">' + record.name + '</option>')

  $('#facility_sector').on 'change', ->
    sectorId = $(this).val()
    $.ajax(
      url: window.location.origin + '/facilities/village_finder?sector=' + sectorId
    ).done (response) ->
      $('#facility_village_id').html('')
      $('#facility_village_id').append('<option></option>')
      appendOption record for record in response
