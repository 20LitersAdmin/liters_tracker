$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['facilities']) &&
    actionMatches(['new', 'edit', 'create', 'update'])

  $('#facility_district').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

  $('#facility_sector').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

  $('#facility_cell').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))
