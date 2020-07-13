$(document).on 'turbolinks:load', ->
  if controllerMatches(['dashboard', 'users'])
    sizeStatsBlocks()

$(window).on 'resize', ->
  if controllerMatches(['dashboard', 'users'])
    sizeStatsBlocks()
