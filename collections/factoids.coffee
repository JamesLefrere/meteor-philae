@Factoids = new Mongo.Collection "factoids"

factoidSchema = new SimpleSchema(
  created:
    type: Date
    autoValue: ->
      new Date()
  user:
    type: String
  isAre:
    type: String
    allowedValues: ["is", "are"]
  thing:
    type: String
    min: 1
    max: 40
  description:
    type: String
    max: 250
)

Factoids.attachSchema factoidSchema