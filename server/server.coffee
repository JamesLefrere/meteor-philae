class MessageParser
  constructor: (options) ->
    # @todo: handle bad options
    @regex = new RegExp options.regex
    @mapping = options.mapping

  mapResults = (matches, mapping) ->
    result = {}
    _.each matches, (match, index) ->
      if typeof match is "string"
        key = mapping[index]
        if key? then result[key] = match
    return result

  parse: (doc) ->
    result = {}
    matches = @regex.exec doc.text
    if !matches then return false
    result = mapResults matches, @mapping
    return result

  parseMultiple: (doc) ->
    results = []
    while matches = @regex.exec doc.text
      results.push mapResults matches, @mapping
    return results

class Philae
  constructor: (params) ->
    @params = params
    @doc = null
    @client = new IRC params

  getKarma: ->
    parser = new MessageParser
      regex: /^(?:karma )([a-z_\-\[\]\\^{}|`][a-z0-9_\-\[\]\\^{}|`]*)/ig
      mapping: 1: "nick"
    result = parser.parse @doc
    if !result then return false
    query = nick: new RegExp "^" + result.nick + "$", "i"
    user = Users.findOne query
    if !user then return false
    @say "#{user.nick}'s karma is #{user.karma}"
    return true

  addKarma: ->
    parser = new MessageParser
      regex: /([a-z_\-\[\]\\^{}|`][a-z0-9_\-\[\]\\^{}|`]*)(\+\+|\-\-)/ig
      mapping: 1: "nick", 2: "direction"
    results = parser.parseMultiple @doc
    if !results then return false
    _.each results, (result) ->
      if result.direction is "--" then inc = -1 else inc = 1
      query = nick: new RegExp "^" + result.nick + "$", "i"
      existing = Users.findOne query
      # Upsert fails to insert on regex
      console.log existing
      if typeof existing is "undefined"
        Users.insert nick: result.nick, karma: inc
      else
        Users.update existing, $inc: karma: inc
    return true

  getFactoid: ->
    parser = new MessageParser
      regex: /^(?:philae)(?:: | |:)(?:what is )?([^?@]*)(?:\?)?( \@.*)?$/ig
      mapping: 1: "thing", 2: "user"
    results = parser.parse @doc
    if !results then return false
    factoids = Factoids.find(thing: results.thing).fetch()
    if factoids.length is 0 then return false

    message = ""
    _.each factoids, (factoid, index) ->
      if index is 0 then message += "Well, "
      message += "#{factoid.user} says #{factoid.thing} #{factoid.isAre} #{factoid.description}. "
      if index is factoids.length - 1
        message += "Make of that what you will."
      if factoids.length is 1
        message = "#{factoid.thing} #{factoid.isAre} #{factoid.description}, according to #{factoid.user}."

    if results.user? then message = results.user.slice(2) + ": " + message
    @say message
    return true

  addFactoid: ->
    parser = new MessageParser
      regex: /^(?:philae(?::| ))(.*?)\s+(is|are)\s+([^\?]*)$/ig
      mapping: 1: "thing", 2: "isAre", 3: "description"
    result = parser.parse @doc
    if !result then return false
    factoid = result
    factoid.user = @doc.handle
    factoid.date = new Date()
    # @todo: fix regex to exclude "what"
    if factoid.thing is "what" then return false
    Factoids.upsert {thing: factoid.thing, user: factoid.user}, $set: factoid
    @say "Got it."
    return true

  connect: ->
    @client.connect()

  say: (message, channel) ->
    if typeof channel is "undefined" then channel = @params.channels[0]
    @client.say channel, message
    return

  parseMessage: (doc) ->
    @doc = doc
    # Ignore if philae is saying it
    if @doc.handle is @params.handle then return false
    @getKarma()
    @addKarma()
    @getFactoid()
    @addFactoid()
    # Delete the message when done
    IRCMessages.remove(doc._id)
    return

philae = new Philae
  server: "irc.freenode.net"
  port: 6667
  nick: "Philae"
  realname: "Philae"
  username: "Philae"
  channels: ["#meteor"]
  debug: false
  stripColors: true

philae.connect()

IRCMessages.find({}, limit: 1, sort: date_time: -1).observe(
  added: (doc) ->
    philae.parseMessage doc
)
