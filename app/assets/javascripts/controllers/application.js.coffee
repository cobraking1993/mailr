App.ApplicationController = Ember.ObjectController.extend(
  init: () ->
    first = App.Folder.find(1)
    @set('currentFolder',first)
  appName: 'MailR'
)

