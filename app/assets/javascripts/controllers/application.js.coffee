Mailr.ApplicationController = Ember.ObjectController.extend(
  init: () ->
    # first = App.Folder.find(1)
    first = 'inbox'
    @set('currentFolder',first)
  appName: 'MailR'
)

