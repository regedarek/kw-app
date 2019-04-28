class Notifications
  constructor: ->
    @notifications = $("[data-behaviour='js-notifications']")
    @setup() if @notifications.length > 0

  setup: ->
    $("[data-behaviour='js-notifications-mark-as-read']").on "click", @handleClick
    $.ajax(
      url: '/notifications.json'
      dataType: 'JSON'
      method: 'GET'
      success: @handleSuccess
    )

  handleClick: (e) =>
    $.ajax(
      url: '/notifications/mark_as_read'
      dataType: 'JSON'
      method: 'POST'
      success: ->
        $("[data-behaviour='js-notifications-unread-count']").text(0)
    )

  handleSuccess: (data) =>
    no_items = "<li style='min-width: 300px; padding: 0.7rem 1rem'><span>Brak nowych notyfikacji</span></li>"
    items = $.map data, (notification) ->
      notification.template

    unread_count = 0
    $.each data, (i, notification) ->
      if notification.unread
        unread_count += 1

    $("[data-behaviour='js-notifications-unread-count']").text(unread_count)
    $("[data-behaviour='js-notifications-items']").html(items)

jQuery ->
  new Notifications
