Puppet::Type.newtype(:foreman_user) do

  @doc = "Adds a new (local) user to authenticate with the Foreman web UI."

  ensurable

  newparam(:name) do
    desc "The name of the user to be added."
    isnamevar
  end

  newparam(:admin_user) do
    desc 'The admin user for the Foreman REST API.'

    validate do |value|
      fail Puppet::Error, "Error: Must enter a valid user for the Foreman to connect to the REST API." if value.empty?
    end
  end

  newparam(:admin_password) do
    desc 'The password for the Foreman admin user.'

    validate do |value|
      fail Puppet::Error, "Error: Must enter a password for the Foreman admin user to connect to the REST API." if value.empty?
    end
  end

  newparam(:host) do
    desc 'The host that the foreman server is running on.'

    validate do |value|
      fail Puppet::Error, "Error: Must enter a valid hostname that has the Foreman service running." if value.empty?
    end
  end

  newparam(:api_admin) do
    desc "Whether or not to make the user an interal API admin."
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:password) do
    desc "The password to authenticate the user with."

    def insync?(is); provider.password; end
  end

  newproperty(:auth_source) do
    desc "The name of the authentication source. Either 'Internal' or the name of the LDAP server that has already been defined in Foreman."

    def insync?(is); provider.is_insync(is, @should); end

    munge do |value|
      value = 'Internal' if value.downcase.eql? 'internal'
      value
    end
  end

  newproperty(:web_admin) do
    desc "Whether or not to make the user an admin in the web UI."
    newvalues(:true, :false)
    defaultto :false

    def insync?(is); provider.is_insync(is, @should); end
  end

  newproperty(:email) do
    desc "The optional email address of the user."

    def insync?(is); provider.is_insync(is, @should); end
  end

  newproperty(:firstname) do
    desc "The first name of the user."

    def insync?(is); provider.is_insync(is, @should); end
  end

  newproperty(:lastname) do
    desc "The first name of the user."

    def insync?(is); provider.is_insync(is, @should); end
  end
end
