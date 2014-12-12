Meteor.publish "users", -> Users.find {}, limit: 100, sort: karma: -1

Meteor.publish "factoids", -> Factoids.find {}, limit: 100, sort: created: -1
