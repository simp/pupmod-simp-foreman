Puppet::Type.newtype(:foreman_location) do

  @doc = "Adds a location to the Foreman database."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the location to add."
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

end
