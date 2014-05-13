Mailr.FoldersConfigController = Em.ArrayController.extend({
  actions: {

    createFolder: ->
      Mailr.folders.pushObject(Mailr.FolderItem.create({ id: Mailr.folders.length, name: @get('folderName'), total: 0, unseen: 0}))
      @set('folderName','')
      return false

    showToggle: (folder) ->
      folder.toggleProperty('show')
      return false

  }
})
