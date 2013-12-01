App.MessagesController = Ember.ArrayController.extend(
  renderTemplate: () ->
    @render('folders',
      controller: 'folders'
      outlet: 'sidebar'
    )
    @render('messages',
      controller: 'messages'
      outlet: 'main'
    )
)

