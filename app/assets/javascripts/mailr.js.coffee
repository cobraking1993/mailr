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
