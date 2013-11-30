App.MessagesRoute = Ember.Route.extend(
  model: (params) ->
    return App.Message.find()
)

