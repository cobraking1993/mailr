App.MessagesRoute = Ember.Route.extend(
  model: (params) ->
    console.log('MessagesRoute: ' + params.folder_id)
    return App.Message.find()
)

