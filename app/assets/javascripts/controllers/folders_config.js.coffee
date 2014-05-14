Mailr.FoldersConfigController = Em.ArrayController.extend({

  folderName: ''

  folderNameValid: ( ->
    return @get('folderName').length > 0
  ).property('folderName')

  actions: {

    createFolder: ->
      if @get('folderNameValid')
        Mailr.folders.pushObject(Mailr.FolderItem.create({ id: Mailr.folders.length, name: @get('folderName'), total: 0, unseen: 0}))
        @set('folderName','')
      return false

    showToggle: (folder) ->
      folder.toggleProperty('show')
      return false

    inboxSet: (folder) ->
      if folder.get('isInbox')
        folder.set('system','')
      else
        folder.set('system','inbox')
      return false

    sentSet: (folder) ->
      if folder.get('isSent')
        folder.set('system','')
      else
        folder.set('system','sent')
      return false

    trashSet: (folder) ->
      if folder.get('isTrash')
        folder.set('system','')
      else
        folder.set('system','trash')
      return false

    draftSet: (folder) ->
      if folder.get('isDraft')
        folder.set('system','')
      else
        folder.set('system','draft')
      return false

    deleteFolder: (folder) ->
      confirmed = confirm(I18n.t('folders.delete_confirmation'))
      if confirmed
        alert('del')
      return false
  }
})
