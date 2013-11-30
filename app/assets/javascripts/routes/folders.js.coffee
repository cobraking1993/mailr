App.FoldersRoute = Ember.Route.extend(
  model: () ->
    return App.Folder.find()
)
