Mailr.FoldersController = Em.ArrayController.extend({

  folderCount: (->
    return @get('content').length
  ).property('content')

  shown: (->
    return @get('content').filterBy('show')
  ).property('content.@each.show')

  system: (->
    return @get('shown').filterBy('system')
  ).property('shown')

  systemCount: (->
    return @get('system').length
  ).property('system')

  noSystem: (->
    return @get('shown').filterBy('system', false)
  ).property('shown')

  noSystemCount: (->
    return @get('noSystem').length
  ).property('noSystem')

})

