Puppet::Type.type(:foreman_smart_proxy).provide(:smart_proxy) do

  desc "Provider for adding a smart proxy source to the Foreman web console."

  require 'rubygems'
  require 'json'
  require 'socket'
  
  def create
    create_smart_proxy
  end

  def destroy
    destroy_smart_proxy
  end

  def exists?
    get_attribute_from_smart_proxy('name') == resource[:name]
  end

  def url
    url = get_attribute_from_smart_proxy('url')
    @url_present = !url.nil?
    url
  end

  def url=(should)
    if @url_present
      update_smart_proxy
    else
      create_smart_proxy
    end
  end

  private

  def get_rest_client(id=nil)
    require 'rest_client'
    if id.nil?
      rest_url = "https://#{resource[:host]}/api/v2/smart_proxies"
    else
      rest_url = "https://#{resource[:host]}/api/v2/smart_proxies/#{id}"
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

  def get_smart_proxy
    tmp = JSON.parse(get_rest_client().get)
    return Hash.new if tmp['results'].empty?
    tmp = tmp['results'].select{ |x| x['name'] == resource[:name] }
    if tmp.size > 0
      return tmp.first
    else
      return Hash.new
    end
  end

  def get_attribute_from_smart_proxy(attr)
    smart_proxy = get_smart_proxy
    if not smart_proxy.empty?
      tmp = smart_proxy[attr]
      return '' if tmp.nil?
      return tmp
    else
      return ''
    end
  end

  def create_smart_proxy
    rc = get_rest_client
    rc.post({ 'smart_proxy' => { 'name' => resource[:name], 'url' => resource[:url] }}.to_json)
  end

  def update_smart_proxy
    rc = get_rest_client(get_attribute_from_smart_proxy('id'))
    rc.put({ 'smart_proxy' => { 'name' => resource[:name], 'url' => resource[:url] }}.to_json)
  end
end
