Puppet::Type.newtype(:foreman_auth_source) do

  @doc = "Adds an auth source to the Foreman database for user authentication."

  ensurable

  newparam(:name) do
    desc "The name of the auth source to add."
    isnamevar
  end

  newparam(:admin_user) do
    desc "The admin user that connects to Foreman's REST API."

    validate do |value|
      fail Puppet::Error, "Error: Must enter a valid user for the Foreman to connect to the REST API." if value.empty?
    end
  end

  newparam(:admin_password) do
    desc "The password the for the admin user that connects to Foreman's REST API."

    validate do |value|
      fail Puppet::Error, "Error: Must enter a password for the Foreman admin user to connect to the REST API." if value.empty?
    end
  end

  newparam(:host) do
    desc "The host the auth source will connect to."
  end

  newproperty(:server) do
    desc 'The LDAP server to connect to.'
  end

  newproperty(:port) do
    desc "The port used to establish the connection."
    defaultto 636

    munge do |value|
      value = value.to_i
      value
    end

    validate do |value|
      fail Puppet::Error, "Not a valid port: #{value}" if not value.to_i.between?(1,65535)
    end
  end

  newproperty(:account) do
    desc "The account used to authenticate."
  end

  newproperty(:account_password) do
    desc "The password associated with the authenticating user."
  end

  newproperty(:base_dn) do
    desc 'The base dn for the auth source.'
  end

  newproperty(:groups_base) do
    desc 'The group base dn for the auth source.'
  end

  newproperty(:attr_login) do
    desc "The login attribute of the user logging in, usually the user ID."
    defaultto 'uid'
  end

  newproperty(:attr_firstname) do
    desc "The first name attribute of a user logging in."
    defaultto 'givenName'
  end

  newproperty(:attr_lastname) do
    desc "The last name attribute of a user logging in."
    defaultto 'sn'
  end

  newproperty(:attr_mail) do
    desc "The email address of the user logging in."
  end

  newproperty(:onthefly_register) do
    desc "Whether or not to register users on the fly."
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:tls) do
    desc "Whether or not to use TLS to connect to the auth source."
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:ldap_filter) do
    desc "The (optional) LDAP filter to use when connecting."
  end

  newproperty(:attr_photo) do
    desc "The photo to assocaite with a given user."
  end
end
