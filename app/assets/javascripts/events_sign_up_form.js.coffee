class KwApp.EventsSignUpForm
  constructor: ($el) ->
    @$el = $el
    @togglePlayer2()
    @$el.find('.js-single-check-box').on 'change', @togglePlayer2
    @$el.find('.js-package-1-select').on 'change', @togglePackageField1
    @$el.find('.js-package-2-select').on 'change', @togglePackageField2

  togglePlayer2: =>
    @$el.find('.js-player-2').toggle(!@$el.find('.js-single-check-box').prop('checked'))

  togglePackageField1: (e) =>
    if $('option:selected', e.currentTarget).data('membership')
      @$el.find('.js-package-1-field').show()
    else
      @$el.find('.js-package-1-field').hide()

  togglePackageField2: (e) =>
    if $('option:selected', e.currentTarget).data('membership')
      @$el.find('.js-package-2-field').show()
    else
      @$el.find('.js-package-2-field').hide()


$ ->
  for el in $('.js-events-sign-up-form')
    new KwApp.EventsSignUpForm($(el))
