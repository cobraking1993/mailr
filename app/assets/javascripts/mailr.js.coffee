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

Mailr.folders = [
        Em.Object.create({ id: 1, show: true, name: 'Inbox', total: 10, unseen: 2, system: 'inbox'}),
        Em.Object.create({ id: 2, show: true, name: 'Sent', total: 110, unseen: 0, system: 'sent'}),
        Em.Object.create({ id: 3, show: true, name: 'Trash', total: 112, unseen: 0, system: 'trash'}),
        Em.Object.create({ id: 4, show: true, name: 'Draft', total: 15, unseen: 0, system: 'draft'}),
        Em.Object.create({ id: 5, show: true, name: 'Folder 5', total: 10, unseen: 0, system: false}),
        Em.Object.create({ id: 6, show: true, name: 'Folder 6', total: 10, unseen: 0, system: false}),
        Em.Object.create({ id: 7, show: true, name: 'Folder 7', total: 10, unseen: 0, system: false}),
        Em.Object.create({ id: 8, show: true, name: 'Folder 8', total: 10, unseen: 0, system: false}),
        Em.Object.create({ id: 9, show: true, name: 'Folder 9', total: 10, unseen: 0, system: false}),
        Em.Object.create({ id: 10, show: true, name: 'Folder 10', total: 10, unseen: 0, system: false})
      ]
