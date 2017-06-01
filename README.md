# devise\_sqreener

Add Sqreen API integration to Devise. Whenever a new user sign up or sign in its IP address and email addressed will be sqreened with security metadata. This plugin also provides the ability to block the said sign in/up using simple rules. Blocking people with disposable email, using TOR or geographically has never been easier. 

## Installation

Add this line to your application Gemfile:

```ruby
gem 'devise_sqreener'
```

and then execute
```bash
$ bundle
```

## Automatic Installation

First if you want IP addresses to be sqreened (as it were) ensure your model use Devise `:trackable`.

Add devise\_sqreener to any or you Devise models using the following generator:

```bash
$ rails generate devise_sqreener MODEL
```

Replace `MODEL` with the class name you want to add devise\_sqreener. This will add the `:sqreenable` flag to your model's Devise modules. The generator will also create a migration file. Currently only ActiveRecord is supported. Then run:

```bash
$ rails db:migrate
```

For the automatic sqreening to work you need to provide [your API token](https://my.sqreen.io) into you devise configuration (in `config/initializers/devise.rb`):
```ruby
Devise.setup do |config|
  #...
  config.sqreen_api_token="TOKEN"
  #...
end
```

## Manual Installation

First if you want IP addresses to be sqreened (as it were) ensure your model use Devise `:trackable`.

Add `:sqreenable` to the devise call in your model:

```ruby
class User < ActiveRecord
  devise :database_authenticable, :confirmable, :sqreenable
end
```
Add the necessary fields to your Devise model migration:

```ruby
class DeviseSqreenerAddToUser < ActiveRecord::Migration
  def change
    add_column :user, :sqreened_email, :text
    # only if you use devise's :trackable
    add_column :user, :current_sqreened_sign_in_ip, :text
    # only if you use devise's :trackable
    add_column :user, :last_sqreened_sign_in_ip, :text
  end
end
```
Then run:

```bash
$ rails db:migrate
```

For the automatic sqreening to work you need to provide [your API token](https://my.sqreen.io) into you devise configuration (in `config/initializers/devise.rb`):
```ruby
Devise.setup do |config|
  #...
  config.sqreen_api_token="TOKEN"
  #...
end
```

## Usage

Signups and Signins are automatically sqreened whenever needed. [Sqreened metada](https://www.sqreen.io/developers.html) are automatically added to your model as serialized fields.
![Activeadmin Screenshor](/doc/activeadmin.png)

## Blocking signups or signins

Blocking sign up or sign in is as easy as adding a predicate in your devise configuration.

```ruby
Devise.setup do |config|
  #...
  # Block signing in from TOR
  config.sqreen_block_sign_in =  -> (email, ip, user)  {ip && ip["is_tor"] }
  # Block signing up with a disposable email address 
  config.sqreen_block_sign_up =  -> (email, ip, user)  {email && email["is_disposable"] }
  #...
end
```

The arguments always are:
* `email`: Current email sqreened metadata (a Hash or nil)
* `ip`: Current ip address sqreened metadata (a Hash or nil)
* `user`: The current instance of your MODEL class trying to sign in/up.

## Contributing to devise\_sqreener
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2017 Sqreen. See LICENSE.txt for further details.

