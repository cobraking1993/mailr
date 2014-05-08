Mailr.FolderRoute = Ember.Route.extend(
  model: (params) ->
    return { }
)
Mailr.FolderIndexRoute = Ember.Route.extend(
  model: (params) ->
    return { name: 'Mój Folder 2' }
)
Mailr.FolderMessagesRoute = Ember.Route.extend(
  model: (params) ->
    return ['1','2','3']
)



