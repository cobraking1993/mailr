Mailr.InputTextComponent = Ember.Component.extend({
  editing: false
  backupText: ''
  isEditing: Ember.computed.equal('editing', true)
  actions: {
    edit: (object) ->
      @set('backupText', object.name)
      @set('editing',true)
    confirm: (object) ->
      @set('editing',false)
      object.set('name', @get('backupText'))
    cancel: () ->
      @set('editing',false)
  }
})

    # edit: (folder) ->
    #   folder.set('editing', true)
    #   folder.set('name_backup', folder.get('name'))
    #   return false

    # editCancel: (folder) ->
    #   folder.set('name', folder.get('name_backup'))
    #   folder.set('editing', false)
    #   return false

    # editConfirm: (folder) ->
    #   folder.set('editing', false)
    #   return false
# <!-- {{object.name}} -->
# <!-- {{#if isEditing}} -->
# <!-- iedit -->
# <!-- {{else}} -->
# <!-- <span {{action "edit"}}>{{object.name}}</span> -->
# <!-- {{/if}} -->
# 
# <!--   <div class="small&#45;4 columns"> -->
# <!--   {{input value=folder.name}} -->
# <!--   </div> -->
# <!--   <div class="small&#45;2 columns"> -->
# <!--   <i {{action "editConfirm" folder}} class="fi&#45;check confirm"}}></i> -->
# <!--   <i {{action "editCancel" folder}} class="fi&#45;x cancel"}}></i> -->
# <!--   </div> -->
# <!-- {{else}} -->
# <!--   <div class="small&#45;6 columns"> -->
# <!--   <span {{action "edit" folder}}>{{folder.name}}</span> -->
# <!--   </div> -->
# <!-- {{/if}} -->
# <!-- [ -->
