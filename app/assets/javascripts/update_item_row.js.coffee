class KwApp.UpdateItemRow
  constructor: (el) ->
    @$el = $el
    console.log 'test'
    @$el.on 'click', '.js-item-rentable', @toggleRentable

  @toggleRentable: (e) =>
    e.preventDefault()
    console.log e

$ ->
  console.log 'test'
  for el in $('.js-item-row')
    console.log el
    new KwApp.UpdateItemRow($(el))
