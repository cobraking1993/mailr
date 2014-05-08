Mailr.Router.map( () ->
  @route('about')
  @route('settings')
  @route('newMessage')
  @resource('folders', () ->
    @route('management')
    @route('new')
  )
  @resource('folder', { path: '/folder/:folder_id' }, () ->
    @route('messages')
  )
)

