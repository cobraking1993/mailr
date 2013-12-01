App.NewmessageRoute = Ember.Route.extend(
  renderTemplate: () ->
    @render('folders',
      controller: 'folders'
      outlet: 'sidebar'
    )
    @render('newmessage',
      outlet: 'main'
    )
)

