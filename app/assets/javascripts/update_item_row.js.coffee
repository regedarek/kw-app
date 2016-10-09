class KwApp.UpdateItemRow
  constructor: ($el) ->
    @$el = $el
    @$el.on 'click', '.js-item-rentable', @toggleRentable
    @$el.find('.js-item-owner').on 'change', 'select', @changeOwner

  toggleRentable: (e) =>
    e.preventDefault()
    $.ajax(
      url: $(e.currentTarget).attr('href')
      type: 'put'
    ).done((response) =>
      @$el.html(response)
      @$el.css('background-color', 'aqua')
      setTimeout (=>
        @$el.css('background-color', '')
      ), 2000
    )
    false

  changeOwner: (e) =>
    e.preventDefault()
    form = @$el.find('.js-item-owner')
    $.ajax(
      url: form.attr('action')
      type: form.attr('method')
      data: form.serialize()
    ).done((response) =>
      @$el.html(response)
      @$el.css('background-color', 'aqua')
      setTimeout (=>
        @$el.css('background-color', '')
      ), 2000
      new KwApp.UpdateItemRow(@$el)
    )
    false

$ ->
  for el in $('.js-item-row')
    new KwApp.UpdateItemRow($(el))
