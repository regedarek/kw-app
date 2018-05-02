class KwApp.Training
  constructor: ($el) ->
    @$el = $el
    @togglePrice()
    @toggleOneDay()
    @$el.find('.js-one-day').on 'change', @toggleOneDay
    @$el.find('.js-price').on 'change', @togglePrice

  togglePrice: =>
    @$el.find('.js-price-row').toggle(@$el.find('.js-price').prop('checked'))

  toggleOneDay: =>
    @$el.find('.js-one-day-row').toggle(!@$el.find('.js-one-day').prop('checked'))

$ ->
  for el in $('.js-course-form')
    new KwApp.Training($(el))
