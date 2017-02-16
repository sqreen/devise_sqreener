# devise\_enricher

Add Sqreen enrich integration to Devise. Whenever a new user sign up or sign in its IP address and email addressed will be enriched with metadata. This plugin also provides the ability to block the said sign in/up using simple rules. Blocking people with disposable email, using TOR or geographically has never been easier. 

## Installation

Add this line to your application Gemfile:

```ruby
gem 'devise_enricher'
```

and then execute
```bash
$ bundle
```

## Automatic Installation

First if you want IP addresses to be enriched ensure your model use Devise `:trackable`.

Add devise\_enricher to any or you Devise models using the following generator:

```bash
$ rails generate devise_enricher MODEL
```

Replace `MODEL` with the class name you want to add devise\_enricher. This will add the `:enrichable` flag to your model's Devise modules. The generator will also create a migration file. Currently only ActiveRecord is supported. Then run:

```bash
$ rails db:migrate
```

For the automatic enrichment to work you need to provide [your TOKEN](https://enrich.sqreen.io) into you devise configuration (in `config/initializers/devise.rb`):
```ruby
Devise.setup do |config|
  #...
  config.sqreen_enrich_token="TOKEN"
  #...
end
```

## Manual Installation

First if you want IP addresses to be enriched ensure your model use Devise `:trackable`.

Add `:enrichable` to the devise call in your model:

```ruby
class User < ActiveRecord
  devise :database_authenticable, :confirmable, :enrichable
end
```
Add the necessary fields to your Devise model migration:

```ruby
class DeviseEnricherAddToUser < ActiveRecord::Migration
  def change
    add_column :user, :enriched_email, :text
    # only if you use devise's :trackable
    add_column :user, :current_enriched_sign_in_ip, :text
    # only if you use devise's :trackable
    add_column :user, :last_enriched_sign_in_ip, :text
  end
end
```
Then run:

```bash
$ rails db:migrate
```

For the automatic enrichment to work you need to provide [your TOKEN](https://enrich.sqreen.io) into you devise configuration (in `config/initializers/devise.rb`):
```ruby
Devise.setup do |config|
  #...
  config.sqreen_enrich_token="TOKEN"
  #...
end
```

## Usage

Signups and Signins are automatically enriched whenever needed. [Enriched metada](https://enrich.sqreen.io) are automatically added to your model as serialized fields.
![Activeadmin Screenshor](/doc/activeadmin.png)

## Blocking signups or signins

Blocking sign up or sign in is as easy as adding a predicate in your devise configuration.

```ruby
Devise.setup do |config|
  #...
  # Block signing in from TOR
  config.enrich_block_sign_in =  -> (email, ip, user)  {ip && ip["is_tor"] }
  # Block signing up with a disposable email address 
  config.enrich_block_sign_up =  -> (email, ip, user)  {email && email["is_disposable"] }
  #...
end
```

The arguments always are:
* `email`: Current email enriched metadata (a Hash or nil)
* `ip`: Current ip address enriched metadata (a Hash or nil)
* `user`: The current instance of your MODEL class trying to sign in/up.

## Contributing to devise\_enricher
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2017 Sqreen. See LICENSE.txt for further details.

