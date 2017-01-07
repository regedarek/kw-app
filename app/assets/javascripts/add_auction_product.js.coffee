class KwApp.AddAuctionProduct
  constructor: ($el) ->
    @$el = $el
    @$el.on 'click', '.js-add-auction-product-link', @cloneProductForm

  cloneProductForm: (e) ->
    e.preventDefault()

$ ->
  for el in $('.js-add-auction-product')
    new KwApp.AddAuctionProduct($(el))
  
  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id', 'g'))
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()
