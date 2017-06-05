# devise\_sqreener

Not everyone who signs up for your app wants to use your service. Wouldn’t it be nice if there was an easy way to automatically block abusers? This project adds the ability to block or flag potentially malicious users of your Rails app to the Devise user authentication module.

Whenever a new user signs up or signs in, their IP address and email address are compared against Sqreen's extensive database of bad apples; you get back a chunk of actionable metadata on those addresses that can be used to set user policies. You can, for example:

* Block users with a history of malicious abuse from signing up
* Prevent users from signing in over TOR.
* Discover whether someone is logging in from two distinct geographic locations at the same time.
* Flag users signing up with disposable email addresses.

Such fun!

## Installation

Of course, the best way to install is with RubyGems! Add this line to your application's Gemfile:

```ruby
gem 'devise_sqreener'
```

and then execute
```bash
$ bundle
```

to download the latest version and install it.

## Install devise_sqreener

Let's assume your user model is called `User`.

First we should note that `devise_sqreened` relies on the Devise `:trackable` strategy for tracking IP addresses. By default, `:trackable` is enabled, but if your use model doesn't include `:trackable`, and you want to enable the IP address filtering features, then you'll need to re-enable `:trackable`. Doing that is a bit beyond the scope of this tutorial, unfortunately. Anyway, the default Devise User model looks something like this, for reference purposes.

```ruby
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
```
OK, so that out of the way, let's add `devise\_sqreener` to the `User` model using the following generator:

```bash
$ rails generate devise_sqreener User
```

This will add the `:sqreenable` flag to your `User` model, and some new fields in the User table of your database. The generator will also create a migration file. Currently only ActiveRecord is supported.

Let's get that migration knocked out, then? Run:

```bash
$ rails db:migrate
```

## Get your API token

For the automatic sqreening to work you need to provide [your Sqreen API token](https://my.sqreen.io) in your Devise configuration, `config/initializers/devise.rb`. You might need to create an account on Sqreen—and once you do you can choose between the 14-day free trial for the full product; if you just want to get straight to the API, however, create a new API Sandbox instead. The API Sandboxes are free forever, albeit rate-limited and with a limited number of requests per month. That will do for our purposes nicely.

Anyway, we're not going to advocate for just leaving service credentials in your code, did you? Ha, of course not. No, we're going to pass it in as an environment variable. So add the following *_verbatim_* to the bottom of your Devise configuration.

```ruby
Devise.setup do |config|
  #...
  config.sqreen_api_token=ENV["SQREEN_API_TOKEN"]  # <- DO NOT PUT YOUR API TOKEN HERE!
  #...
end
```

And pass it in to your app's runtime environment with something like

```
export SQREEN_API_TOKEN="PASTE_YOUR_TOKEN_HERE"
```

There are lots of ways to get environment variables into your Rails app, of course—you should follow the practices used for your particular app if they aren't set in this way.


## Looking at security metadata

Sign-ups and sign-ins are automatically sqreened whenever needed. [Sqreened metada](https://www.sqreen.io/developers.html) are automatically added to your model as serialized fields.
![Activeadmin Screenshor](/doc/activeadmin.png)

## Configuring your user Sqreening policy

Policies are implemented as predicates in your Devise configuration, `config/initializers/devise.rb`. There are two predicates, one for signing up and one for signing in. The predicates can do really anything you like, including firing off notifications, or flagging the user in some way. But the most important thing is deciding whether to block the user from completing the sign-up or sign-in action.

The arguments to the predicates are:
* `email`: Current email sqreened metadata (a Hash or nil)
* `ip`: Current ip address sqreened metadata (a Hash or nil)
* `user`: The current instance of your MODEL class trying to sign in/up.

The return value should be a boolean. If your predicate returns `true`, the action will be blocked. If your predicate returns `false`, the action will not be blocked.

The `email` hash passed to the predicate has the following structure:

* `email`: string The email address queried.
* `risk_score`: number The assessed risk that this email address is being used by a malevolent actor. Values range from 0 to 100. Anything greater than 80 is really bad and should be dropped; anything greater than about 40 is worth flagging and keeping an eye on.
* `is_email_harmful`: boolean Does the email address itself pose a direct security risk? E.g., does the email address contain embedded JavaScript?
* `is_known_attacker`: boolean Was this email address used as part of a security attack?
* `high_risk_security_events_count`: number The number of high-risk security events (e.g. SQL injection attacks) involving this email address.
* `security_events_count`: number The number of all security events (both high-risk and low-risk) involving this email address.
* `is_disposable`: boolean Does this email's domain belong to a known vendor of disposable, temporary, or anonymized email addresses?
* `is_email_malformed`: boolean Is the email malformed according to RFC 5322?

The `ip` hash passed to the predicate has the following structure:

* `ip`: string The IP address queried.
* `ip_version`: number The version of the IP address queried. Either 4 or 6.
* `risk_score`: number The assessed risk that this IP address is being used by a malevolent actor. Values range from 0 to 100. Anything greater than 80 is really bad and should be dropped; anything greater than about 40 is worth flagging and keeping an eye on.
* `is_known_attacker`: boolean Was this IP address used as part of a security attack?
* `high_risk_security_events_count`: number The number of high-risk security events (e.g. SQL injection attacks) originating from this IP address.
* `security_events_count`: number The number of all security events (both high-risk and low-risk) originating from this IP address.
* `ip_geo`: object The geographical location associated with this IP address.
* `ip_geo.latitude` number The latitude of the location.
* `ip_geo.longitude `number The longitude of the location.
* `ip_geo.country_code` string The ISO ALPHA-3 Code for the country that this location exists within.
* `is_datacenter`: boolean Does this IP address belong to a known datacenter, such as AWS or Google Cloud?
* `is_vpn`: boolean Does this IP address belong to a known VPN?
* `is_proxy`: boolean Does this IP address belong to a known proxy server?
* `is_tor`: boolean Is this IP address a known Tor exit point?

Let's suppose that we want to block all sign-ups and sign-ins over TOR:

```ruby
Devise.setup do |config|
  #...
  # Block signing in from TOR
  config.sqreen_block_sign_in =  -> (email, ip, user)  {ip && ip["is_tor"] }
  # Block signing up from TOR 
  config.sqreen_block_sign_up =  -> (email, ip, user)  {ip && ip["is_tor"] }
  #...
end
```

Or perhaps you just want to look at Sqreen's pre-calculated risk score for the email address to make this determination:
```ruby
Devise.setup do |config|
  #...
  # Block signing up with a risky email address 
  config.sqreen_block_sign_up =  -> (email, ip, user)  {email && email["risk_score"] > 70 }
  #...
end
```

The possibilities are...well, let's be honest, they're not exactly endless, but there is a great deal of flexibility in crafting these policies.

## Let us know how it works for you

So, that's about all there is to it! Having a problem? Have an idea for how we could improve this Devise plugin? [Open an issue](https://github.com/sqreen/devise_sqreener/issues/new), and let us know what we can do better. 