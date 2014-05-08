# http://emberjs.com/guides/models/#toc_store
# http://emberjs.com/guides/models/pushing-records-into-the-store/

Mailr.Store = DS.Store.extend({
  adapter: DS.RESTAdapter.create()
})

# Override the default adapter with the `DS.ActiveModelAdapter` which
# is built to work nicely with the ActiveModel::Serializers gem.
# Mailr.ApplicationAdapter = DS.ActiveModelAdapter.extend({
# 
# })
