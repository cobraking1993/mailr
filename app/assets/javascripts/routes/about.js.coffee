Mailr.AboutRoute = Ember.Route.extend(
  renderTemplate: () ->
    @render('aboutSidebar',
      outlet: 'sidebar'
    )
    @render('about',
      outlet: 'main'
    )
)
