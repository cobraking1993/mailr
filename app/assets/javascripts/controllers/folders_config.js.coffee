Mailr.FoldersConfigController = Em.ArrayController.extend({

  sortProperties: ['sort']
  sortAscending: true

  folderName: ''

  folderNameValid: ( ->
    return @get('folderName').length > 0
  ).property('folderName')

  actions: {

    sortDown: (folder) ->
      length = Mailr.folders.length
      return if folder.sort == length - 1
      sort = folder.get('sort')
      next = Mailr.folders.findBy('sort',sort + 1)
      nextSort = next.get('sort')
      next.set('sort',sort)
      folder.set('sort',nextSort)

    sortUp: (folder) ->
      return if folder.sort == 0
      sort = folder.get('sort')
      previous = Mailr.folders.findBy('sort',sort - 1)
      previousSort = previous.get('sort')
      previous.set('sort',sort)
      folder.set('sort',previousSort)

    createFolder: ->
      if @get('folderNameValid')
        sort = Mailr.folders.length
        id = sort + 1
        Mailr.folders.pushObject(Mailr.FolderItem.create({ id: id, sort: sort, name: @get('folderName'), total: 0, unseen: 0}))
        @set('folderName','')
        for f in Mailr.folders
          do (f) ->
            f.toggleProperty('force')
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
        sort = folder.get('sort')
        if Mailr.folders.length > 1
          f.decrementProperty('sort') for f in Mailr.folders when f.sort > sort
          for f in Mailr.folders
            do (f) ->
              f.toggleProperty('force')
        Mailr.folders.removeObject(folder)
      return false
  }
})
