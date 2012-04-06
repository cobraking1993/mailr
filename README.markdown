[![Dependency Status](https://gemnasium.com/musashimm/mailr.png?travis)](https://gemnasium.com/musashimm/mailr)

**NOTE** The last stable version is 0.8.6. Now I try to moved code to Rails 3.2.2 and add Boostrap from Tweeter as default theme. Not all sources that you can find in _MASTER_ branch were already moved, so some views can be broken.

## Introduction
_MailR_ is a IMAP mail client based on _Ruby on Rails_ platform.

**NOTE** All path and filenames are based on _Rails.root_ directory.

## Requirements

In _Rails 3_ all dependencies should be defined in file _Gemfile_. All needed gems can be installed using bundler.

## Installation procedure

* Checkout the source code.
* Install all dependiences. Check if proper gems (sqlite3/mysql/postgresql) are defined in _Gemfile_ and installed. Use _bundler_ for that:

```shell
bundle install
```

* Check _config/defaults.yml_ for proper values.
* Prepare config/database.yml file (see _config/database.yml.example_).
* Migrate database (rake db:migrate)
* Start rails server if applicable
* Point your browser to application URL:
  For local access: http://localhost:3000
  For remote access: http://some_url/mailr
* Using browser do basic setup. If You make a mistake delete all data from DB using rake task:

```shell
rake db:clear_data
```

* Use it.

## Specific configuration

For themes: if server sends files with no content in production mode comment out

```ruby
config.action_dispatch.x_sendfile_header = "X-Sendfile"
```

in _config/environments/production.rb_ file.
