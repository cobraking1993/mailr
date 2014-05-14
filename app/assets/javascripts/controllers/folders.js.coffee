Mailr.FoldersController = Em.ArrayController.extend({

  folderCount: (->
    return @get('content').length
  ).property('content.@each')

  shown: (->
    return @get('content').filterBy('show').sortBy('sort')
  ).property('content.@each.show')

  system: (->
    return @get('shown').filterBy('isSystem')
  ).property('shown.@each.system')

  systemCount: (->
    return @get('isSystem').length
  ).property('isSystem')

  notSystem: (->
    return @get('shown').filterBy('isSystem', false)
  ).property('shown.@each.system')

  notSystemCount: (->
    return @get('notSystem').length
  ).property('notSystem')

})

