Puppet::Type.type(:foreman_location).provide(:location) do

  desc "Provider for adding a location to the Foreman web console."

  require 'rubygems'
  require 'json'
  require 'socket'

  # Functions for ensurable

  def create
    create_location
  end

  def destroy
    destroy_location
  end

  def exists?
    get_attribute_from_location('name') == resource[:name]
  end

  private

  def get_rest_client(id=nil)
    require 'rest_client'
    if id.nil?
      rest_url = "https://#{resource[:host]}/api/v2/locations"
    else
      rest_url = "https://#{resource[:host]}/api/v2/locations/#{id}"
    end
    rest_client = RestClient::Resource.new(
      rest_url,
      {
      :headers => {
        :content_type    => :json,
        :accept          => :json,
      },
      :ssl_ca_file     => '/etc/pki/cacerts/cacerts.pem',
      :ssl_client_cert => OpenSSL::X509::Certificate.new(File.read("/etc/pki/public/#{Socket.gethostname}.pub")),
      :ssl_client_key  => OpenSSL::PKey::RSA.new(File.read("/etc/pki/private/#{Socket.gethostname}.pem")),
      :ssl_version     => :TLSv1_2,
      :user            => resource[:admin_user],
      :password        => resource[:admin_password],
      :verify_ssl      => OpenSSL::SSL::VERIFY_PEER,
      }
    )
    rest_client
  end

  def get_location
    tmp = JSON.parse(get_rest_client().get)
    return Hash.new if tmp['results'].empty?
    tmp = tmp['results'].select{ |x| x['name'] == resource[:name] }
    if tmp.size > 0
      return tmp.first
    else
      return Hash.new
    end
  end

  def get_attribute_from_location(attr)
    location = get_location
    if not location.empty?
      tmp = location[attr]
      return '' if tmp.nil?
      return tmp
    else
      return ''
    end
  end

  def create_location
    rc = get_rest_client
    rc.post({ 'location' => { 'name' => resource[:name] }}.to_json)
  end

  def update_location
    rc = get_rest_client(get_attribute_from_location('id'))
    rc.put({ 'location' => { 'name' => resource[:name] }}.to_json)
  end

  def destroy_location
    rc = get_rest_client(get_attribute_from_location('id'))
    rc.delete({ 'location' => { 'name' => resource[:name] }}.to_json)
  end
end
