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

  setupController: (controller, model) ->
    controller.set('content', model)
    @controllerFor('folders').set('content', Mailr.folders)

  renderTemplate: () ->
    @render('foldersList',
        controller: 'folders',
        outlet: 'sidebar'
    )
    @render('folder/messages')
)



