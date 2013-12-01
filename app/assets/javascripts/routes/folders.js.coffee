App.FoldersRoute = Ember.Route.extend(
  model: (params) ->
    console.log('FoldersRoute: ' + params.folder_id)
    return App.Folder.find()
  renderTemplate: () ->
    @render('folders',
      outlet: 'sidebar'
    )
)
