Mailr.FolderRoute = Ember.Route.extend(
  model: (params) ->
      return { id: 1, indent: 'folder1', name: 'Folder 1'}
)
# Mailr.FolderIndexRoute = Ember.Route.extend(
#   model: (params) ->
#     return { name: 'Mój Folder 2' }
# )
Mailr.FolderMessagesRoute = Ember.Route.extend(

  model: (params) ->
    return [
      { id: 1, title: 'Wiadomość 1'},
      { id: 2, title: 'Wiadomość 2'},
      { id: 3, title: 'Wiadomość 3'},
      { id: 4, title: 'Wiadomość 4'},
      { id: 5, title: 'Wiadomość 5'}]

  # model: (params) ->
  #   return [ { id: 1, indent: 'folder1', name: 'Folder 1'}, { id: 2, indent: 'folder2', name: 'Folder 2'}, { id: 3, indent: 'folder3', name: 'Folder 3'}, { id: 4, indent: 'folder4', name: 'Folder 4'}, { id: 5, indent: 'folder5', name: 'Folder 5'}]

  setupController: (controller, model) ->
    controller.set('content', model)
    controller.set('folders', Mailr.folders)

  renderTemplate: () ->
    # controller = @controllerFor('folders')
    @render('foldersList',
        # controller: 'folders'
        outlet: 'sidebar'
        into: 'application'
    )
    @render('folder/messages')
)



