Puppet::Type.type(:foreman_user).provide(:user) do

  desc "Provider for adding a user who can login to the Foreman web console."

  commands :foreman_rake => '/usr/sbin/foreman-rake'
  defaultfor :kernel => 'Linux'

  require 'rubygems'
  require 'json'
  require 'socket'

  def initialize(*args)
    @rest_client = nil
    @password_insync = false
    super(*args)
  end

  # Functios for ensurable

  def create
    update_foreman_users('post')
  end

  def destroy
    update_foreman_users('delete', get_attribute_from_user('id'))
  end

  def exists?
    unless defined?(RestClient)
      # This is the only way that we could determine to
      # reliably reload the Gems during the middle of a
      # Puppet run.
      Gem.refresh
      require 'rest_client'
    end

    begin
      @password_insync = (get_attribute_from_user('login') == resource[:name])
    rescue RestClient::Unauthorized => e
      if e.http_code.to_s == '401'
        @password_insync = false
        return true
      elsif e.http.code.to_s == '403'
        return false
      else
        fail Puppet::Error, "HTTP Response: #{e.http_code} returned from provided foreman server."
      end
    end
    @password_insync
  end

  # Getters, all used for insync?

  def password
    if !@password_insync && resource[:api_admin] == :true
      update_admin_pass_with_rake
    end
    return resource[:password] if @password_insync
    return nil
  end

  def auth_source
    get_attribute_from_user('auth_source_name')
  end

  def web_admin
    get_attribute_from_user('admin').to_s.to_sym
  end

  def email
    get_attribute_from_user('mail')
  end

  def firstname
    get_attribute_from_user('firstname')
  end

  def lastname
    get_attribute_from_user('lastname')
  end

  # Generic insync to help handle empty strings and nils. Puppet should have nils...
  def is_insync(is, should)
    is_empty = Array(is).first.to_s.empty?

    if is_empty
      return is_empty
    else
      return Array(is).eql?(Array(should))
    end
  end

  # Setters. This is hacky and awful looking. Unfortunately, Puppet requires the existence of these
  # or else all updates fail. All updates happen in flush, which is called at the end of the run. Since
  # there is a network connection to a REST interface, the goal was to limit this as much as possible.

  def password=(should);    end
  def auth_source=(should); end
  def web_admin=(should);   end
  def email=(should);       end
  def firstname=(should);   end
  def lastname=(should);    end

  # Override flush to update/create users.
  def flush
    if exists?
      update_foreman_users('put', get_attribute_from_user('id'))
    else
      update_foreman_users('post')
    end
  end

  private

  def get_rest_client(api,*id)
    host = resource[:host]

    if id.empty?
      url = "https://#{resource[:host]}/api/v2/#{api}"
    else
      url = "https://#{resource[:host]}/api/v2/#{api}/#{id.first}"
    end

    rc = RestClient::Resource.new(
      url,
      {
      :headers => {
        :content_type    => :json,
        :accept          => :json,
      },
      :ssl_ca_file     => resource[:ssl_ca_file],
      :ssl_client_cert => OpenSSL::X509::Certificate.new(File.read(resource[:ssl_client_cert])),
      :ssl_client_key  => OpenSSL::PKey::RSA.new(File.read(resource[:ssl_client_key])),
      :ssl_version     => resource[:ssl_version],
      :user            => resource[:admin_user],
      :password        => resource[:admin_password],
      :verify_ssl      => OpenSSL::SSL::VERIFY_PEER,
      }
    )
    rc
  end

  def rest_client
    @rest_client ||= get_rest_client('users')
  end

  def try_auth
    return true if not resource[:auth_source].eql? 'Internal'
    rc                    = get_rest_client('status')
    rc.options[:user]     = resource[:name]
    rc.options[:password] = resource[:password]
    res                   = nil
    rc.get { |response, request, result| res = result }
    return true  if res.code.eql? '200' or res.code.eql? '403'
    return false if res.code.eql? '401'
    fail Puppet::Error, "HTTP Response: #{res.code} returned from provided foreman server."
  end

  def get_user
    tmp = JSON.parse( rest_client.get )['results'].select{ |x| x['login'] == resource[:name] }
    if tmp.size > 0
      return tmp.first
    else
      return Hash.new
    end
  end

  def get_attribute_from_user(attr)
    user = get_user
    if not user.empty?
      return user[attr]
    else
      return nil
    end
  end

  def update_admin_pass_with_rake
    begin
      $stdout.reopen('/dev/null', 'w')

      system("cd /usr/share/foreman; #{command(:foreman_rake)} permissions:reset user='#{resource[:name]}' password='#{resource[:password]}'")
    rescue
      fail Puppet::Error, "Unable to update admin credentials for user: #{resource[:name]}."
    ensure
      $stdout = STDOUT
    end
  end

  def update_foreman_users(operation,*id)
    if id.empty?
      _id = nil
    else
      _id = id.first
    end

    rest_client = get_rest_client('users',_id)
    if operation.eql? 'post'
      rest_client.post({ 'user' => get_options }.to_json)
    elsif operation.eql? 'put'
      rest_client.put({ 'user' => get_options }.to_json)
    elsif operation.eql? 'delete'
      rest_client.delete
    else
      fail Puppet::Error, "Error: Unknown operation - #{operation} not a valid option for Foreman REST API."
    end
  end

  def get_options
    opts = Hash.new
    opts['login']          = resource[:name]
    opts['auth_source_id'] = get_auth_source_id
    if resource[:password].empty?
      opts['password']     = nil
    else
      opts['password']     = resource[:password]
    end
    opts['admin']          = resource[:web_admin]
    if resource[:email].empty?
      opts['mail']         = nil
    else
      opts['mail']         = resource[:email]
    end
    if resource[:firstname].empty?
      opts['firstname']    = nil
    else
      opts['firstname']    = resource[:firstname]
    end
    if resource[:lastname].empty?
      opts['lastname']    = nil
    else
      opts['lastname']    = resource[:lastname]
    end
    opts
  end

  def get_auth_source_id
    return 1 if resource[:auth_source].eql? 'Internal'
    auth_sources = JSON.parse(get_rest_client('auth_source_ldaps').get)
    auth_source = auth_sources['results'].select { |x| x['name'] == resource[:auth_source] }.first
    auth_source['id']
  end
end
