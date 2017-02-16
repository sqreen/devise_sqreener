# After each authentication check if sign_in should have been authorized.
# This is only triggered when the user is explicitly set (with set_user)
# and on authentication. Retrieving the user from session (:fetch) does
# not trigger it.
Warden::Manager.prepend_after_set_user :except => :fetch do |record, warden, options|
  if warden.authenticated?(options[:scope]) &&
     record.respond_to?(:current_ip_address=)
    record.current_ip_address = warden.request.remote_ip
    if record.respond_to?(:enrich_block_sign_in?) &&
       record.enrich_block_sign_in?
      scope = options[:scope]
      warden.logout(scope)
      throw :warden, :scope => scope, :message => record.inactive_message
    end
  end
end
