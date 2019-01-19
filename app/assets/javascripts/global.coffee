$(document).on 'turbolinks:load', ->
  $('.prevent-default').on 'click', ->
    event.preventDefault
    false
  $('#loading_screen').hide()

$(document).on 'turbolinks:request-start', ->
  $('#loading_screen').show()
