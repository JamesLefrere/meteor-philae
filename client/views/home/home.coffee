Router.map ->
  @route "home",
    path: "/"
    subscriptions: ->
      @subscribe "users"
    data: ->
      users: Users.find {}, limit: 100, sort: karma: -1
