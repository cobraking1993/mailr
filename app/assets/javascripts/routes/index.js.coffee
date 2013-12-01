App.IndexRoute = Ember.Route.extend(
  afterModel: () ->
    @transitionTo('messages', @controllerFor('application').get('currentFolder'))
)

