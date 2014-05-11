Mailr.SettingsRoute = Ember.Route.extend({

  model: () ->
    return [
      { id: 1, indent: 'folder1', name: 'Folder 1'},
      { id: 2, indent: 'folder2', name: 'Folder 2'},
      { id: 3, indent: 'folder3', name: 'Folder 3'},
      { id: 4, indent: 'folder4', name: 'Folder 4'},
      { id: 5, indent: 'folder5', name: 'Folder 5'}
    ]

  afterModel: () ->
    @transitionTo('settings.lookandfeel')

  renderTemplate: () ->
    @render('foldersList', outlet: 'sidebar')
    @render('settings')

})

