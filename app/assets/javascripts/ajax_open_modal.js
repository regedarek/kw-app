 $('img.image-modal').on('click', function() {
  var img = $(this).data('img-src');
  var revealId = $(this).data('reveal-id');
  $('#' + revealId).html('<img src="' + img + '" alt=""/>').foundation('open');
});
