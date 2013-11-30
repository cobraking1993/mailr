App.Message = DS.Model.extend({
  from: DS.attr('string'),
  to: DS.attr('string'),
  subject: DS.attr('string'),
  arrivedAt: DS.attr('string'),
  body: DS.attr('string')
});

App.Message.FIXTURES = [
{id: 1, from: 'some@address.com', to: 'myaddress@e.pl', subject: 'Taxes', arrivedAt: '2013-12-12 23:34', body: 'Lorem Ipsum 111111'},
{id: 2, from: 'barbara@address.com', to: 'george@e.pl', subject: 'Pool party', arrivedAt: '2013-10-09 14:25', body: 'Lorem Ipsum 222222'},
{id: 3, from: 'janosik@address.com', to: 'maryna@e.pl', subject: 'Nowy odcinek', arrivedAt: '2013-15-05 10:05', body: 'Lorem Ipsum 3333'},
]
