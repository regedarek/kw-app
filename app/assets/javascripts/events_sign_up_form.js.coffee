class KwApp.EventsSignUpForm
  constructor: ($el) ->
    @$el = $el
    @togglePlayer2()
    @$el.find('.js-single-check-box').on 'change', @togglePlayer2

  togglePlayer2: =>
    @$el.find('.js-player-2').toggle(!@$el.find('.js-single-check-box').prop('checked'))

$ ->
  for el in $('.js-events-sign-up-form')
    new KwApp.EventsSignUpForm($(el))
