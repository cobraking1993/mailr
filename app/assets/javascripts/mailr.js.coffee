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

Mailr.FolderItem = Em.Object.extend({

  system: null,
  show: true,
  total: 0,
  unseen: 0,

  isShown: Ember.computed.equal('show', true)
  isInbox: Ember.computed.equal('system','inbox')
  isSent: Ember.computed.equal('system','sent')
  isTrash: Ember.computed.equal('system','trash')
  isDraft: Ember.computed.equal('system','draft')
  hasUnseen: Em.computed.gte('unseen',0)

  isSystem: ( ->
    sys = @get('system')
    return sys != undefined && sys != null && sys != ''
  ).property('system')

})

Mailr.folders = [
        Mailr.FolderItem.create({ id: 1, name: 'Inbox', total: 10, unseen: 2, system: 'inbox'}),
        Mailr.FolderItem.create({ id: 2, name: 'Sent', total: 110, unseen: 0, system: 'sent'}),
        Mailr.FolderItem.create({ id: 3, name: 'Trash', total: 112, unseen: 0, system: 'trash'}),
        Mailr.FolderItem.create({ id: 4, name: 'Draft', total: 15, unseen: 0, system: 'draft'}),
        Mailr.FolderItem.create({ id: 5, name: 'Docs'})
        Mailr.FolderItem.create({ id: 6, name: 'Private'})
      ]
