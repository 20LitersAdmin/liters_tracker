$(document).on 'turbolinks:load', ->
  if controllerMatches(['stories']) and actionMatches(['image'])
    $('#image_upload').change () ->
      if $(this).val() == ""
        $('#submit').attr('disabled', 'disabled')
      else
        $('#submit').removeAttr('disabled')
