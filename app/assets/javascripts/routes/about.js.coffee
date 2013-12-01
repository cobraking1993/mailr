App.AboutRoute = Ember.Route.extend(
  renderTemplate: () ->
    @render('about_sidebar',
      outlet: 'sidebar'
    )
    @render('about',
      outlet: 'main'
    )
)
