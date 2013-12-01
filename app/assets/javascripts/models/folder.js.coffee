App.Folder = DS.Model.extend(
  ident: DS.attr('string')
  name: DS.attr('string')
)

App.Folder.FIXTURES = [
  id: 1
  ident: 'folder1'
  name: 'Folder One'
,
  id: 2
  ident: 'folder2'
  name: 'Folder Two'
,
  id: 3
  ident: 'folder3'
  name: 'Folder Three'
,
  id: 4
  ident: 'folder4'
  name: 'Folder Four'
]

