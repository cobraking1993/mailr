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
        Em.Object.create({ id: 1, name: 'Inbox', total: 10, unseen: 2, system: 1}),
        Em.Object.create({ id: 2, name: 'Sent', total: 110, unseen: 0, system: 2}),
        Em.Object.create({ id: 3, name: 'Trash', total: 112, unseen: 0, system: 3}),
        Em.Object.create({ id: 4, name: 'Draft', total: 15, unseen: 0, system: 4}),
        Em.Object.create({ id: 5, name: 'Folder 5', total: 10, unseen: 2}),
        Em.Object.create({ id: 6, name: 'Folder 6', total: 10, unseen: 2}),
        Em.Object.create({ id: 7, name: 'Folder 7', total: 10, unseen: 2}),
        Em.Object.create({ id: 8, name: 'Folder 8', total: 10, unseen: 2}),
        Em.Object.create({ id: 9, name: 'Folder 9', total: 10, unseen: 2}),
        Em.Object.create({ id: 10, name: 'Folder 10', total: 10, unseen: 2})
      ]
