$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['facilities']) &&
    actionMatches(['new', 'edit', 'create', 'update'])
