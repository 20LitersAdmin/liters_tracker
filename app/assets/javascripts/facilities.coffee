$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['facilities', 'sectors']) &&
    actionMatches(['new', 'edit', 'create', 'update', 'report'])

  $('#facility_district').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

  $('#facility_sector').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

  $('#facility_cell').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

  $('#sector_cell').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))
