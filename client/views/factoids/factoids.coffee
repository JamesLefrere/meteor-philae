Router.map ->
  @route "factoids",
    subscriptions: ->
      @subscribe "factoids"
    data: ->
      factoids: Factoids.find {}, limit: 100, sort: created: -1
