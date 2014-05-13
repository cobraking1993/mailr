Mailr.FoldersController = Em.ArrayController.extend({

  folderCount: (->
    return @get('content').length
  ).property('content')

  shown: (->
    return @get('content').filterBy('show')
  ).property('content.@each.show')

  system: (->
    return @get('shown').filterBy('isSystem')
  ).property('shown')

  systemCount: (->
    return @get('isSystem').length
  ).property('isSystem')

  notSystem: (->
    return @get('shown').filterBy('isSystem', false)
  ).property('shown')

  notSystemCount: (->
    return @get('notSystem').length
  ).property('notSystem')

})

