$(document).on 'turbolinks:load', ->
  $('.prevent-default').on 'click', ->
    event.preventDefault
    false
