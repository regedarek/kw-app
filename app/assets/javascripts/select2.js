$(document).ready(function() {
  let selectedTab = window.location.hash;
  $(selectedTab + "-label").trigger('click');

  $('.js-select-multiple').select2({
    theme: "foundation"
  });
});
