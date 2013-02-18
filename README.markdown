[![Dependency Status](https://gemnasium.com/musashimm/mailr.png)](https://gemnasium.com/musashimm/mailr)

## Introduction
_MailR_ is a IMAP mail client based on _Ruby on Rails_ platform.

**NOTE** All path and filenames are based on _Rails.root_ directory.

## Requirements

In _Rails 3_ and above all dependencies should be defined in file _Gemfile_. All needed gems can be installed using bundler.

## Installation procedure

* Checkout the source code.
* Install all dependiences. Check if proper gems (sqlite3/mysql/postgresql) are defined in _Gemfile_ and installed. Use _bundler_ for that:

```shell
bundle install
```

* Check _config/settings.yml_ for proper values.
* Prepare config/database.yml file.
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

None
