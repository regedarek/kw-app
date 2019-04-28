class Notifications
  constructor: ->
    @notifications = $("[data-behaviour='js-notifications']")
    @setup() if @notifications.length > 0

  setup: ->
    $("[data-behaviour='js-notifications-mark-as-read'").on "click", @handleClick
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
        $("[data-behaviour='js-notifications-unread-count'").text(0)
    )

  handleSuccess: (data) =>
    items = $.map data, (notification) ->
      "<li style='min-width: 300px;'><a href='#{notification.url}' class='button primary'><b>#{notification.actor.display_name}</b> dodał Cię do przejścia</a></li>"
    no_items = "<li style='min-width: 300px; padding: 0.7rem 1rem'><span>Brak nowych notyfikacji</span></li>"
    if items.length > 0
      $("[data-behaviour='js-notifications-unread-count'").text(items.length)
      $("[data-behaviour='js-notifications-items'").html(items)
    else
      $("[data-behaviour='js-notifications-items'").html(no_items)

jQuery ->
  new Notifications
