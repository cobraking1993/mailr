App.Router.map( () ->
  @route('about')
  @route('settings')
  @resource('folders', () ->
    @route('new')
    @resource('folder', { path: '/:folder_id' }, () ->
      @resource('messages', () ->
        @resource('message', { path: '/:message_id'}, () ->
        )
      )
    )
  )
)

