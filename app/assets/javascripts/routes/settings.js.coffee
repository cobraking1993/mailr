Mailr.SettingsRoute = Ember.Route.extend({

  model: () ->
    return Mailr.folders

  afterModel: () ->
    @transitionTo('settings.lookandfeel')

  renderTemplate: () ->
    @render('foldersList', outlet: 'sidebar')
    @render('settings')

})

