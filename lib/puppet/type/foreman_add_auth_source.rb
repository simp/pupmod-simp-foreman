Puppet::Type.newtype(:foreman_add_auth_source) do

  @doc = "Adds an auth source to the foreman database for user authentication."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the auth source to add."
    isnamevar

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('name')
    end

    def sync
      provider.post_auth_type
    end
  end

  newproperty(:admin_user) do
    desc "The admin user that connects to Foreman's REST API."

    validate do |value|
      fail Puppet::Error, "Error: Must enter a valid user for the Foreman to connect to the REST API." if value.empty?
    end
  end

  newproperty(:admin_password) do
    desc "The password the for the admin user that connects to Foreman's REST API."

    validate do |value|
      fail Puppet::Error, "Error: Must enter a password for the Foreman admin user to connect to the REST API." if value.empty?
    end
  end

  newproperty(:host) do
    desc "The host the auth source will connect to."

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('host')
    end

    munge do |value|
      value.downcase
    end

    validate do |value|
      fail Puppet::Error, "Error: Must enter a valid hostname for the auth source." if val.empty?
    end
  end

  newproperty(:port) do
    desc "The port used to establish the connection."
    defaultto '636'

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('port')
    end

    validate do |value|
      scope.function_validate_port(value)
    end
  end

  newproperty(:account) do
    desc "The account used to authenticate."

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('account')
    end
  end

  newproperty(:account_password) do
    desc "The password associated with the authenticating user."

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_account_password
  end

  newproperty(:base_dn) do
    desc "The type of auth source to use."

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('base_dn')
    end
  end

  newproperty(:attr_login) do
    desc "The login attribute of the user logging in, usually the user ID."
    defaultto 'uid'

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('uid')
    end
  end

  newproperty(:attr_firstname) do
    desc "The first name attribute of a user logging in."
    defaultto 'givenName'

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('attr_firstname')
    end
  end

  newproperty(:attr_lastname) do
    desc "The last name attribute of a user logging in."
    defaultto 'sn'

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('attr_lastname')
    end
  end

  newproperty(:attr_mail) do
    desc "The email address of the user logging in."

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('attr_mail')
    end
  end

  newproperty(:onthefly_register) do
    desc "Whether or not to register users on the fly."
    newvalues(:true,:false)
    defaultto :false

    def insync?(is)
      is.to_s == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('onthefly_register')
    end
  end

  newproperty(:tls) do
    desc "Whether or not to use TLS to connect to the auth source."
    newvalues(:true,:false)
    defaultto :true

    def insync?(is)
      is.to_s == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('tls')
    end
  end

  newproperty(:ldap_filter) do
    desc "The (optional) LDAP filter to use when connecting."

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('ldap_filter')
    end
  end

  newproperty(:attr_photo) do
    desc "The photo to assocaite with a given user."

    def insync?(is)
      is == @should.to_s
    end

    def retrieve
      provider.get_attribute_from_auth_source('attr_photo')
    end
  end

  def flush
    provider.put_auth_type
  end
end
