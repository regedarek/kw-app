//= require jquery
//= require jquery_ujs
//= require foundation
//= require foundation-datepicker
//= require rails-jquery-tokeninput
//= require nested_form_fields
//= require kw_app
//= require trix
//= require_tree .

$(function(){ $(document).foundation(); });

$('.js-send-on-enter').keypress(function(e){
  if(e.which == 13){
       $(this).closest('form').submit();
   }
});
