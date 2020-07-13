$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['dashboard'])

  sizeStatsBlocks()

$(window).on 'resize', ->
  return unless controllerMatches(['dashboard'])

  sizeStatsBlocks()
