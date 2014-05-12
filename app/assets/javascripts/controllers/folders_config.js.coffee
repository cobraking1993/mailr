Mailr.FoldersConfigController = Em.ArrayController.extend({
  actions: {
    createFolder: ->
      Mailr.folders.pushObject(Em.Object.create({ id: Mailr.folders.length, name: @get('folderName'), total: 0, unseen: 0}))
      @set('folderName','')
  }
})
