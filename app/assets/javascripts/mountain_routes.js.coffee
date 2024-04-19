class KwApp.MountainRoutes
  constructor: ($el) ->
    @$el = $el
    @$el.find('.js-sport-type').on 'change', @toggleSportType
    @$el.find('.js-route-area').hide()
    @$el.find('.js-route-kurtyka-difficulty').hide()
    @initSportType()

  initSportType: () =>
    if $.inArray($('option:selected', $('.js-sport-type')).text(), ['Sportowe wspinanie', 'Tradowe wspinanie']) > -1
      @$el.find('.js-route-length').hide()
      @$el.find('.js-route-partners').hide()
      @$el.find('.js-route-hidden').hide()
      @$el.find('.js-route-kurtyka-difficulty').show()
      @$el.find('.js-route-custom-difficulty').hide()
      @$el.find('.js-route-area').show()
    else
      @$el.find('.js-route-length').show()
      @$el.find('.js-route-custom-difficulty').show()
      @$el.find('.js-route-partners').show()
      @$el.find('.js-route-hidden').show()

  toggleSportType: (e) =>
    if $.inArray($('option:selected', e.currentTarget).text(), ['Sportowe wspinanie', 'Tradowe wspinanie']) > -1
      @$el.find('.js-route-length').hide()
      @$el.find('.js-route-partners').hide()
      @$el.find('.js-route-hidden').hide()
      @$el.find('.js-route-kurtyka-difficulty').show()
      @$el.find('.js-route-custom-difficulty').hide()
      @$el.find('.js-route-area').show()
    else
      @$el.find('.js-route-length').show()
      @$el.find('.js-route-custom-difficulty').show()
      @$el.find('.js-route-partners').show()
      @$el.find('.js-route-hidden').show()

$ ->
  for el in $('.js-routes-form')
    new KwApp.MountainRoutes($(el))
