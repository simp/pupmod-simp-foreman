Puppet::Type.newtype(:foreman_smart_proxy) do

  @doc = "Adds a smart proxy to the Foreman database."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the auth source to add."
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
    desc 'The host that the Foreman service is running on.'

    validate do |value|
      fail Puppet::Error, "Error: Must enter a valid host that the Foreman service is running on." if value.empty?
    end
  end

  newparam(:ssl_ca_file) do
    desc 'The CA file by which the the :host should be validated'
    defaultto '/etc/foreman/pki/cacerts/cacerts.pem'

    validate do |value|
      fail Puppet::Error, 'Error: Must be an absolute path.' unless value[0].chr == '/'
    end
  end

  newparam(:ssl_client_cert) do
    desc 'The client PKI certificate that will be recognized by the :host'
    defaultto "/etc/foreman/pki/public/#{Facter.value(:fqdn)}.pub"

    validate do |value|
      fail Puppet::Error, 'Error: Must be an absolute path.' unless value[0].chr == '/'
    end
  end

  newparam(:ssl_client_key) do
    desc 'The client PKI private key that will be recognized by the :host'
    defaultto "/etc/foreman/pki/private/#{Facter.value(:fqdn)}.pem"

    validate do |value|
      fail Puppet::Error, 'Error: Must be an absolute path.' unless value[0].chr == '/'
    end
  end

  newparam(:ssl_version) do
    desc <<-EOS
      The SSL version that should be negotiated with the remote host

      You can get a list of valid versions by running the following on the client system:
        ruby -ropenssl -e 'puts OpenSSL::SSL::SSLContext::METHODS'
    EOS

    defaultto 'TLSv1_2'
  end

  newproperty(:url) do
    desc "The URL of the smart proxy, optionally with port."

    validate do |value|
      fail Puppet::Error, "Error: Must enter a URL for the smart proxy." if value.empty?
    end
  end

  autorequire(:service) do
    ['foreman-proxy']
  end
end
