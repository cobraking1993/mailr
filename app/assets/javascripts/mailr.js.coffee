#= require ./store
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./components
#= require_tree ./templates
#= require_tree ./routes
#= require ./router
#= require_self

Mailr.Settings = Ember.Object.extend({
})

Mailr.settings = Mailr.Settings.create({
  language: 'en',
  domain: 'example.com',
  name: 'Joe Doe',
})

Mailr.folders = []

Mailr.FolderItem = Em.Object.extend({

  system: null
  show: true
  total: 0
  unseen: 0
  force: false
  editing: false
  name_backup: ''

  isShown: Ember.computed.equal('show', true)
  isInbox: Ember.computed.equal('system','inbox')
  isSent: Ember.computed.equal('system','sent')
  isTrash: Ember.computed.equal('system','trash')
  isDraft: Ember.computed.equal('system','draft')
  hasUnseen: Em.computed.gte('unseen',0)
  isEditing: Ember.computed.equal('editing', true)

  isSystem: ( ->
    sys = @get('system')
    return sys != undefined && sys != null && sys != ''
  ).property('system')

  isLast: ( ->
    return @get('sort') == Mailr.folders.length - 1
  ).property('sort','force')

  isFirst: ( ->
    return @get('sort') == 0
  ).property('sort','force')

})

Mailr.folders.pushObject(Mailr.FolderItem.create({ id: 1, sort: 0, name: 'Inbox', total: 10, unseen: 2, system: 'inbox'}))
Mailr.folders.pushObject(Mailr.FolderItem.create({ id: 2, sort: 1, name: 'Sent', total: 110, unseen: 0, system: 'sent'}))
Mailr.folders.pushObject(Mailr.FolderItem.create({ id: 3, sort: 2, name: 'Trash', total: 112, unseen: 0, system: 'trash'}))
Mailr.folders.pushObject(Mailr.FolderItem.create({ id: 4, sort: 3, name: 'Draft', total: 15, unseen: 0, system: 'draft'}))
Mailr.folders.pushObject(Mailr.FolderItem.create({ id: 5, sort: 4, name: 'Docs'}))
Mailr.folders.pushObject(Mailr.FolderItem.create({ id: 6, sort: 5, name: 'Private'}))

