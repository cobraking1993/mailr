App.FoldersConfigurationController = Ember.ArrayController.extend(
  folderName: null

  actions:
    createFolder: () ->
      console.log('create')
      name = @get('folderName')
      newFolder = @store.createRecord(App.Folder)
      newFolder.set('id',name)
      newFolder.set('ident',name)
      newFolder.set('name',name)
      # newFolder.save()
      @set('folderName',null)

)

