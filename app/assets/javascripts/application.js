//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require foundation
//= require_tree .

$(document).on('turbolinks:load', function() {
  $(function(){ $(document).foundation(); });
});
