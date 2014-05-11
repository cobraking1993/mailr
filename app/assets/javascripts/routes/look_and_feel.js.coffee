Mailr.SettingsLookandfeelRoute = Ember.Route.extend({

  model: () ->
    return Mailr.settings

  setupController: (controller, model) ->
    controller.set('content', model)
    controller.set('languages', ['en', 'pl'])

})

