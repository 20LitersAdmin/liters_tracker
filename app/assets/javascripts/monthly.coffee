$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['monthly']) &&
    actionMatches(['show'])

  toggleSortLinks = (elem, direction) ->
    target = if direction == 'up' then 'a.sort[data-sort="down"]' else 'a.sort[data-sort="up"]'
    twin = elem.parents('div.sort-div').find(target)
    elem.toggle()
    twin.toggle()

  toggleTable = (tech, direction) ->
    target = $('table#tech_' + tech)
    if direction == 'up'
      target.find('thead').hide()
      target.find('tbody').hide()
    else
      target.find('thead').show()
      target.find('tbody').show()

  $('a.sort').on 'click', ->
    direction = $(this).attr('data-sort')
    tech = $(this).attr('data-tech')
    toggleSortLinks($(this), direction)
    toggleTable(tech, direction)
