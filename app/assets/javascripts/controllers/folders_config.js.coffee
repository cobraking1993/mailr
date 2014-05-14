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
      console.log(length)
      console.log(folder.sort)
      index = Mailr.folders.indexOf(folder)
      console.log(index)

    sortUp: (folder) ->
      length = Mailr.folders.length
      return if folder.sort == 0
      console.log(folder.sort)

    createFolder: ->
      if @get('folderNameValid')
        sort = Mailr.folders.length
        id = sort + 1
        previous = Mailr.folders.findBy('sort', sort - 1)
        previous.toggleProperty('force')
        Mailr.folders.pushObject(Mailr.FolderItem.create({ id: id, sort: sort, name: @get('folderName'), total: 0, unseen: 0}))
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

    edit: (folder) ->
      folder.set('editing', true)
      folder.set('name_backup', folder.get('name'))
      return false

    editCancel: (folder) ->
      folder.set('name', folder.get('name_backup'))
      folder.set('editing', false)
      return false

    editConfirm: (folder) ->
      folder.set('editing', false)
      return false

    deleteFolder: (folder) ->
      # confirmed = confirm(I18n.t('folders.delete_confirmation'))
      # if confirmed
      #   sort = folder.get('sort')
      #   previous = Mailr.folders.findBy('sort', sort - 1)
      #   if folder.First
      #     to_update = Mailr.folders.findBy('sort', sort 

      #   previous.toggleProperty('force')
      #   Mailr.folders.removeObject(folder)
      return false
  }
})
