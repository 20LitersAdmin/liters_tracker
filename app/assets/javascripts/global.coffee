$(document).on 'turbolinks:load', ->
  $('.prevent-default').on 'click', ->
    event.preventDefault
    false
  $('#loading_screen').hide()
  $('[data-toggle="popover"]').popover()

  ### global show and hide functions
  # 1. Ensure the target element has an id (e.g. 'report_section')
  # 2. Create a link/button with the same id prepended by 'show_' (e.g. 'show_report_section')
  # 3. Ensure the button has the class 'global-toggle-btn'
  # 4. Ensure another button exists with same id prepended by 'hide_' and the same 'global-btn' class (e.g. 'hide_report_section')
  # 5. Choose which button will be hidden first by adding the class 'start-hidden'
  ###
  $('.global-toggle-btn.start-hidden').hide()

  idParser = (idStr) ->
    idStr.replace('show_','').replace('hide_','')

  idFlipper = (idStr) ->
    if idStr.includes('show_')
      str = idStr.replace('show_', 'hide_')
    else
      str = idStr.replace('hide_', 'show_')
    str

  $('.global-toggle-btn').on 'click', ->
    id = $(this).attr('id')
    targetId = idParser(id)
    $('#' + targetId).toggle()
    sisterId = idFlipper(id)
    $('.global-toggle-btn#' + sisterId).show()
    $(this).hide()
    event.preventDefault
    false

$(document).on 'turbolinks:request-start', ->
  $('#loading_screen').show()

$(document).on 'turbolinks:request-end', ->
  $('#loading_screen').hide()
