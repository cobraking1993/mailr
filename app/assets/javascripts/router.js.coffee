App.Router.map( () ->
  @route('about')
  @resource('folders', () ->
    @route('new')
    @resource('folder', { path: '/:folder_id' }, () ->
    )
  )
)

