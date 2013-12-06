App.MessagesRoute = Ember.Route.extend(
  model: (params) ->
    # console.log('MessagesRoute: ' + params)
    return App.Message.find()

  renderTemplate: () ->
    @render('messages_header',
      controller: 'messages'
      outlet: 'header'
    )
    @render('messages',
      controller: 'messages'
      outlet: 'local'
    )
  # console.log(@controllerFor("application").get("currentRouteName"))
  # console.log(@controllerFor("application").get("currentPath"))
)

App.MessagesIndexRoute = App.MessagesRoute
# App.MessagesIndexRoute = Ember.Route.extend(
#   model: (params) ->
#     console.log('MessagesIndexRoute: ' + params)
#     return App.Message.find()
# 
#   renderTemplate: () ->
#     @render('messages_header',
#       controller: 'messages'
#       outlet: 'header'
#     )
#     @render('messages',
#       controller: 'messages'
#       outlet: 'local'
#     )
# )

App.MessageRoute = Ember.Route.extend(
  # model: (params) ->
  #   console.log('MessageRoute: ' + params)
  #   return []
  # model: (params) ->
  #   return App.Message.find(params.message_id)
  # setupController: (controller) ->
  #   controller.set('model', {id: 1, from: 'some@address.com', to: 'myaddress@e.pl', subject: 'Taxes', arrivedAt: '2013-12-12 23:34', body: 'Lorem Ipsum 111111'})

  renderTemplate: () ->
    @render('message_header',
      controller: 'message'
      outlet: 'header'
    )
    @render('message',
      controller: 'message'
      outlet: 'local'
    )

)
# 
# App.MessageIndexRoute = Ember.Route.extend(
#   model: (params) ->
#     return ({}
#     )
#   # App.Message.find(params.message_id)
# 
#   renderTemplate: () ->
#     @render('message_header',
#       controller: 'message'
#       outlet: 'header'
#     )
#     @render('message',
#       controller: 'message'
#       outlet: 'local'
#     )
# 
# )
