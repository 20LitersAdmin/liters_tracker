function showImage(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader()
    reader.onload = function (e) {
      $('#image_preview')
        .attr('src', e.target.result);
      $('#image_thumbnail_preview')
        .attr('src', e.target.result);

      $('#image_preview_wrapper')
        .removeClass('hide');
      $('#image_thumbnail_preview_wrapper')
        .removeClass('hide');
    }
    reader.readAsDataURL(input.files[0]);
  }
}

$("document").ready(function(){

  $('#image_upload').on('change', function() {
    showImage(this);
  })
})