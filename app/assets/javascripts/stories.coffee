# function showImage(input) {
#   if (input.files && input.files[0]) {
#     var reader = new FileReader()
#     reader.onload = function (e) {
#       $('#image_preview')
#         .attr('src', e.target.result);
#       $('#image_thumbnail_preview')
#         .attr('src', e.target.result);

#       $('#image_preview_wrapper')
#         .removeClass('hide');
#       $('#image_thumbnail_preview_wrapper')
#         .removeClass('hide');
#     }
#     reader.readAsDataURL(input.files[0]);
#   }
# }

# $("document").ready(function(){

#   $('#image_upload').on('change', function() {
#     showImage(this);
#   })
# })

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['stories']) &&
    actionMatches(['new', 'edit', 'create', 'update'])

  $('#image_upload').on 'change', ->
    return unless !!$('#image_upload').val().length

    form = document.getElementById('story_form')
    formData = new FormData(form)

    xhr = new XMLHttpRequest()
    xhr.open 'post', '/localize_image', true
    xhr.send(formData)
