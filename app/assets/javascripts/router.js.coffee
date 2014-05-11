Mailr.Router.map( () ->
  @route('about')
  @resource('settings', () ->
    @route('lookandfeel')
    @route('identity')
  )
  @route('newMessage')
  @resource('folders', () ->
    @route('config')
    @route('new')
  )
  @resource('folder', { path: '/folder/:folder_id' }, () ->
    @route('messages')
    @resource('message', { path: '/message/:message_id' }, () ->
    )
  )
)

