Mailr.ComposeRoute = Ember.Route.extend(

  model: () ->
    return Mailr.folders

  setupController: (controller, model) ->
    controller.set('content', model)
    @controllerFor('folders').set('content', model)

  renderTemplate: () ->
    @render('foldersList', {
      controller: 'folders',
      outlet: 'sidebar'
    }
    )
    @render('compose')
)

