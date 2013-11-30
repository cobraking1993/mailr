App.FolderRoute = Ember.Route.extend(
  model: (params) ->
    return App.Folder.find(params.folder_id)
)


