App.FoldersRoute = Ember.Route.extend(
  model: (params) ->
    # console.log('FoldersRoute: ' + params.folder_id)
    # console.log('Router: ' + App.Router.router.currentParams)
    return App.Folder.find()
  renderTemplate: () ->
    @render('folders',
      outlet: 'sidebar'
    )
)

App.FolderRoute = Ember.Route.extend(

  model: (params) ->
    return App.Folder.find(params.folder_id)

  setupController: (controller, folder) ->
    @_super(controller, folder)
    @controllerFor('application').set('currentFolder', folder)

)
