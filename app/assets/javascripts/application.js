//= require jquery
//= require jquery_ujs
//= require foundation
//= require foundation-datepicker
//= require_tree .

$(function(){ $(document).foundation(); });

$(document).ready(function(){
	$('#dp1').fdatepicker({
		format: 'mm-dd-yyyy',
		disableDblClickSelection: true
	});
});
