App.Router.map( () ->
  @route('about')
  @route('settings')
  @route('newmessage')
  @resource('folders', () ->
    @route('configuration')
    @route('new')
    @resource('folder', { path: ':folder_id' }, () ->
      @resource('messages', () ->
        @resource('message', { path: ':message_id'}, () ->
        )
      )
    )
  )
)

