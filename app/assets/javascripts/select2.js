$(document).ready(function() {
  let selectedTab = window.location.hash;
  $('.nav-link[href="' + selectedTab + '"]' ).trigger('click');

  $('.js-select-multiple').select2({
    theme: "foundation"
  });
});
