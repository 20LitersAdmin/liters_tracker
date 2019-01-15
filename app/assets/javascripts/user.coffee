# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('.dtp-datetime').datetimepicker({
    format: 'YYYY-MM-DD HH:mm Z'
  })

  $('#user_confirmed_at').datetimepicker('date', $('#user_confirmed_at').attr('value'))
  $('#user_locked_at').datetimepicker('date', $('#user_locked_at').attr('value'))
