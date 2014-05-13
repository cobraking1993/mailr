Mailr.FoldersConfigController = Em.ArrayController.extend({
  actions: {

    createFolder: ->
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
      if folder.get('deleteConfirmed')
      else
        folder.set('deleteConfirmed', true)
      return false
  }
})
