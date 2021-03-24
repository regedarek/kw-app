//= require jquery
//= require jquery_ujs
//= require foundation
//= require foundation-datepicker
//= require rails-jquery-tokeninput
//= require nested_form_fields
//= require kw_app
//= require trix
//= require jqplot
//= require jqplot/plugins/dateAxisRenderer
//= require jqplot/plugins/cursor
//= require jqplot/plugins/pointLabels
//= require jqplot/plugins/ohlcRenderer
//= require jqplot/plugins/highlighter
//= require debounce
//= require_tree .

$(function(){ $(document).foundation(); });

$('[data-open-details]').click(function (e) {
  e.preventDefault();
  $(this).next().toggleClass('is-active');
  $(this).toggleClass('is-active');
});

$('.sim-thumb').on('click', function() {
  $('#main-product-image').attr('src', $(this).data('image'));
})

$('.js-send-on-enter').keypress(function(e){
  if(e.which == 13){
       $(this).closest('form').submit();
   }
});

if (document.getElementById("demo")) {  
  var countDownDate = new Date(document.getElementById("demo").dataset.expired).getTime();

  // Update the count down every 1 second
  var x = setInterval(function() {

    // Get today's date and time
    var now = new Date().getTime();

    // Find the distance between now and the count down date
    var distance = countDownDate - now;

    // Time calculations for days, hours, minutes and seconds
    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60) + days * 24);
    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);

    // Display the result in the element with id="demo"
    document.getElementById("demo").innerHTML = hours + "h "
    + minutes + "m " + seconds + "s ";

    // If the count down is finished, write some text
    if (distance < 0) {
      clearInterval(x);
      document.getElementById("demo").innerHTML = "Głosowanie zostało zamknięte.";
    }
  }, 1000);
}
