Mailr.SettingsRoute = Ember.Route.extend(
  renderTemplate: () ->
    @render('folders',
      controller: 'folders'
      outlet: 'sidebar'
    )
    @render('settings')
)

