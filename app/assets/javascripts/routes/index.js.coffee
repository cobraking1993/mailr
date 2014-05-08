Mailr.IndexRoute = Ember.Route.extend(
  afterModel: () ->
    @transitionTo('folder.messages', @controllerFor('application').get('currentFolder'))
)
