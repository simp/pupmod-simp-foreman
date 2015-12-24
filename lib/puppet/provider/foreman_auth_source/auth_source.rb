Puppet::Type.type(:foreman_auth_source).provide(:auth_source) do

  desc "Provider for adding an auth source to the Foreman web console."

  require 'rubygems'
  require 'json'
  require 'socket'

  commands :psql => 'psql'
  commands :su => 'su'
  commands :sh => '/bin/sh'
  commands :foreman_rake => 'foreman-rake'

  def initialize(*args)
    @rest_client = nil
    super(*args)
  end

  # Functions for ensurable

  def create
    update_foreman_auth_sources('post')
  end

  def destroy
    update_foreman_auth_sources('delete',get_attribute_from_auth_source('id'))
  end

  def exists?
    unless defined?(RestClient)
      # This is the only way that we could determine to
      # reliably reload the Gems during the middle of a
      # Puppet run.
      Gem.refresh
      require 'rest_client'
    end

    get_attribute_from_auth_source('name').eql? resource[:name]
  end

  # Getters, used for insync?

  def ldap_server
    get_attribute_from_auth_source('host')
  end

  def port
    get_attribute_from_auth_source('port')
  end

  def account
    get_attribute_from_auth_source('account')
  end

  # This, obnoxiously, cannot be returned via the REST API, so we just grab it
  # directly from the DB.
  def account_password
    get_account_password
  end

  def base_dn
    get_attribute_from_auth_source('base_dn')
  end

  # Currently groups_base isn't returned from the REST API. There's a bug report.
  def groups_base
    get_groups_base
#    get_attribute_from_auth_source('groups_base')
  end

  def attr_login
    get_attribute_from_auth_source('attr_login')
  end

  def attr_firstname
    get_attribute_from_auth_source('attr_firstname')
  end

  def attr_lastname
    get_attribute_from_auth_source('attr_lastname')
  end

  def attr_mail
    get_attribute_from_auth_source('attr_mail')
  end

  def onthefly_register
    get_attribute_from_auth_source('onthefly_register').to_s.to_sym
  end

  def tls
    get_attribute_from_auth_source('tls').to_s.to_sym
  end

  def ldap_filter
    get_attribute_from_auth_source('ldap_filter')
  end

  def attr_photo
    get_attribute_from_auth_source('attr_photo')
  end

  # Setters. This is hacky and awful looking. Unfortunately, Puppet requires the existence of these
  # or else all updates fail. All updates happen in flush, which is called at the end of the run. Since
  # there is a network connection to a REST interface, the goal was to limit this as much as possible.

  def ldap_server=(should)       end
  def port=(should)              end
  def account=(should)           end
  def account_password=(should)  end
  def base_dn=(should)           end
  def groups_base=(should)       end
  def attr_login=(should)        end
  def attr_firstname=(should)    end
  def attr_lastname=(should)     end
  def attr_mail=(should)         end
  def onthefly_register=(should) end
  def tls=(should)               end
  def ldap_filter=(should)       end
  def attr_photo=(should)        end

  # Override flush to update/create users.
  def flush
    if exists?
      update_foreman_auth_sources('put',get_attribute_from_auth_source('id'))
    else
      update_foreman_auth_sources('post')
    end
  end

  private

  def get_rest_client(id=nil)
    if id.nil?
      url = "https://#{resource[:host]}/api/v2/auth_source_ldaps"
    else
      url = "https://#{resource[:host]}/api/v2/auth_source_ldaps/#{id}"
    end
    rest_client = RestClient::Resource.new(
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
    rest_client
  end

  def rest_client
    @rest_client ||= get_rest_client
  end

  def get_auth_source
    tmp = JSON.parse( rest_client.get )['results'].select{ |x| x['name'] == resource[:name] }
    if tmp.size > 0
      return tmp.first
    else
      return Hash.new
    end
  end

  def get_attribute_from_auth_source(attr)
    auth_source = get_auth_source
    if not auth_source.empty?
      tmp = auth_source[attr]
      return '' if tmp.nil?
      return tmp
    else
      return ''
    end
  end

  def get_account_password
    account_password = %x(echo "SELECT account_password FROM auth_sources WHERE name='#{get_attribute_from_auth_source("name")}';" | #{command(:su)} - foreman -s #{command(:sh)} -c "#{command(:psql)}").split("\n")[2].strip

    # We need to find a better way to handle this, or have The Foreman team update their code
    if account_password =~ /encrypted-/
      %x(#{command(:foreman_rake)} db:auth_sources_ldap:decrypt)
      account_password = %x(echo "SELECT account_password FROM auth_sources WHERE name='#{get_attribute_from_auth_source("name")}';" | #{command(:su)} - foreman -s #{command(:sh)} -c "#{command(:psql)}").split("\n")[2].strip
    end

    %x(#{command(:foreman_rake)} db:auth_sources_ldap:encrypt)

    account_password
  end

  def get_groups_base
    %x(echo "SELECT groups_base FROM auth_sources WHERE name='#{get_attribute_from_auth_source("name")}';" | #{command(:su)} - foreman -s #{command(:sh)} -c "#{command(:psql)}").split("\n")[2].strip
  end

  def update_foreman_auth_sources(type,*id)
    if id.empty?
      _id = nil
    else
      _id = id.first
    end

    rest_client = get_rest_client(_id)
    if type.eql? 'post'
      rest_client.post( {'auth_source_ldap' => options}.to_json )
    elsif type.eql? 'put'
      rest_client.put( {'auth_source_ldap' => options}.to_json )
    elsif type.eql? 'delete'
      rest_client.delete
    else
      fail Puppet::Error, "Error: Unknown operation - #{type} not a valid option for Foreman REST API."
    end
  end

  def options
    opts = Hash.new
    opts['account']           = get_resource(:account)
    opts['account_password']  = get_resource(:account_password)
    opts['attr_firstname']    = get_resource(:attr_firstname)
    opts['attr_lastname']     = get_resource(:attr_lastname)
    opts['attr_login']        = get_resource(:attr_login)
    opts['attr_mail']         = get_resource(:attr_mail)
    opts['attr_photo']        = get_resource(:attr_photo)
    opts['base_dn']           = get_resource(:base_dn)
    opts['groups_base']       = get_resource(:groups_base)
    opts['host']              = get_resource(:ldap_server)
    opts['ldap_filter']       = get_resource(:ldap_filter)
    opts['name']              = get_resource(:name)
    opts['onthefly_register'] = get_resource(:onthefly_register)
    opts['port']              = get_resource(:port)
    opts['tls']               = get_resource(:tls)
    opts['type']              = 'AuthSourceLdap'
    opts
  end

  def get_resource(attr)
    if resource[attr].to_s.empty?
      return nil
    else
      return resource[attr]
    end
  end
end
