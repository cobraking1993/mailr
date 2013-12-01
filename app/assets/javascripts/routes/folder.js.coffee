App.FolderRoute = Ember.Route.extend(
  model: (params) ->
    console.log('FolderRoute: ' + params.folder_id)
    return App.Folder.find(params.folder_id)
)


