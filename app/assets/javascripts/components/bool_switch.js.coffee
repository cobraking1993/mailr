Mailr.BoolSwitchComponent = Ember.Component.extend({
  classNameBindings: [':bool-switch', 'boolValue:active']
  actions: {
    toggleMore: () ->
      @toggleProperty('isShowingMore')
  }
})

# look
# Setting 1
# {{ input value=address }}
# Setting 2
# {{ textarea value=body }}
# {{ partial 'debug' }}
# {{#if light}}
# is on
# {{else}}
# is off
# {{/if}}
# {{#if door}}
# is on
# {{else}}
# is off
# {{/if}}
# <p>asdasdas
# {{settings}}
# </p>
# {{language}}
# zxxzzxzxzx
# {{bool-switch name='light' boolValue=light more='qqqqqqq'}}
# {{bool-switch name='door' boolValue=door more='cccccccc'}}
