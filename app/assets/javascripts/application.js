//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require foundation
//= require foundation-datepicker
//= require_tree .

$(document).on('turbolinks:load', function() {
  $(function(){ $(document).foundation(); });
});

$(document).ready(function(){
	$('#dp1').fdatepicker({
		format: 'mm-dd-yyyy',
		disableDblClickSelection: true
	});
});
