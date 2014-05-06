Mailr.Router.map( () ->
  @route('about')
  @route('settings')
  @route('newMessage')
  @resource('folders', () ->
    @route('management')
    @route('new')
    @resource('folder', { path: ':folder_id' }, () ->
      @resource('messages', () ->
        @resource('message', { path: ':message_id'}, () ->
        )
      )
    )
  )
)

