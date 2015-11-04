require 'spec_helper'

describe 'foreman' do
  shared_examples_for "a structured module" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('foreman') }
    it { is_expected.to contain_class('foreman::params') }
    ### it { is_expected.to contain_class('foreman::install').that_comes_before('foreman::config') }
    ### it { is_expected.to contain_class('foreman::config') }
    ### it { is_expected.to contain_class('foreman::service').that_subscribes_to('foreman::config') }
  end

  shared_examples_for "a foreman installation" do
    it { is_expected.to contain_package('foreman') }
    it { is_expected.to contain_package('foreman-cli') }
    it { is_expected.to contain_package('foreman-postgresql') }
    it { is_expected.to contain_package('foreman-proxy') }
    it { is_expected.to contain_package('foreman-release') }
    it { is_expected.to contain_package('foreman-selinux') }

    it { is_expected.to contain_service('foreman') }
    it { is_expected.to contain_service('foreman-proxy') }

    it { is_expected.to contain_class('foreman::database') }
    it { is_expected.to contain_class('foreman::proxy') }
    it { is_expected.to contain_class('foreman::proxy::facts') }
    it { is_expected.to contain_class('foreman::proxy::puppet') }
    it { is_expected.to contain_class('foreman::proxy::puppetca') }
    it { is_expected.to contain_class('foreman::settings') }
    it { is_expected.to contain_class('foreman::ssl') }


    it { is_expected.to contain_file('/etc/foreman') }
    it { is_expected.to contain_file('/etc/foreman/database.yml') }
    it { is_expected.to contain_file('/etc/foreman/plugins') }
    it { is_expected.to contain_file('/etc/foreman-proxy/settings.d') }
    it { is_expected.to contain_file('/etc/foreman-proxy/settings.d/facts.yml') }
    it { is_expected.to contain_file('/etc/foreman-proxy/settings.d/foreman_proxy.yml') }
    it { is_expected.to contain_file('/etc/foreman-proxy/settings.d/puppetca.yml') }
    it { is_expected.to contain_file('/etc/foreman-proxy/settings.d/puppet.yml') }
    it { is_expected.to contain_file('/etc/foreman-proxy/settings.yml') }
    it { is_expected.to contain_file('/etc/foreman-proxy/ssl') }
    it { is_expected.to contain_file('/etc/foreman-proxy/ssl/certs') }
    it { is_expected.to contain_file('/etc/foreman-proxy/ssl/certs/ca.pem') }
    it { is_expected.to contain_file('/etc/foreman-proxy/ssl/private_keys') }
    it { is_expected.to contain_file('/etc/foreman/settings.yaml') }
    it { is_expected.to contain_file('/etc/foreman/ssl') }
    it { is_expected.to contain_file('/etc/foreman/ssl/certs') }
    it { is_expected.to contain_file('/etc/foreman/ssl/certs/ca.pem') }
    it { is_expected.to contain_file('/etc/foreman/ssl/private_keys') }
    it { is_expected.to contain_file('/reports/foreman.rb') }

    it { is_expected.to contain_foreman__user('admin') }
    it { is_expected.to contain_foreman_user('admin') }
    it { is_expected.to contain_pki__copy('/etc/foreman') }
    it { is_expected.to contain_pki__copy('/simp') }
  end


  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "foreman class without any parameters" do
          let(:params) {{ }}
          it_behaves_like "a structured module"
          it_behaves_like "a foreman installation"
          it { is_expected.to contain_foreman_smart_proxy('foo')}
          it { is_expected.to contain_foreman__smart_proxy('foo')}
          it { is_expected.to contain_file('/etc/foreman-proxy/ssl/certs/foo.example.com.pem') }
          it { is_expected.to contain_file('/etc/foreman-proxy/ssl/private_keys/foo.example.com.pem') }
          it { is_expected.to contain_file('/etc/foreman/ssl/certs/foo.example.com.pem') }
          it { is_expected.to contain_file('/etc/foreman/ssl/private_keys/foo.example.com.pem') }
          it { is_expected.to contain_file('/etc/httpd/conf.d/05-foreman-ssl.d') }
          it { is_expected.to contain_file('/etc/httpd/conf.d/05-foreman.d') }
          it { is_expected.to contain_file('/etc/puppet/foreman.yaml') }
          ### it { is_expected.to contain_file('') }
          ## it { is_expected.to contain_class('foreman').with_client_nets( ['127.0.0.1/32']) }
        end

        ### context "foreman class with firewall enabled" do
        ###   let(:params) {{
        ###     :client_nets     => ['10.0.2.0/24'],
        ###     :tcp_listen_port => '1234',
        ###     :enable_firewall => true,
        ###   }}
        ###   ###it_behaves_like "a structured module"
        ###   it { is_expected.to contain_class('foreman::config::firewall') }

        ###   it { is_expected.to contain_class('foreman::config::firewall').that_comes_before('foreman::service') }
        ###   it { is_expected.to create_iptables__add_tcp_stateful_listen('allow_foreman_tcp_connections').with_dports('1234') }
        ### end

        ### context "foreman class with selinux enabled" do
        ###   let(:params) {{
        ###     :enable_selinux => true,
        ###   }}
        ###   ###it_behaves_like "a structured module"
        ###   it { is_expected.to contain_class('foreman::config::selinux') }
        ###   it { is_expected.to contain_class('foreman::config::selinux').that_comes_before('foreman::service') }
        ###   it { is_expected.to create_notify('FIXME: selinux') }
        ### end

        ### context "foreman class with auditing enabled" do
        ###   let(:params) {{
        ###     :enable_auditing => true,
        ###   }}
        ###   ###it_behaves_like "a structured module"
        ###   it { is_expected.to contain_class('foreman::config::auditing') }
        ###   it { is_expected.to contain_class('foreman::config::auditing').that_comes_before('foreman::service') }
        ###   it { is_expected.to create_notify('FIXME: auditing') }
        ### end

        ### context "foreman class with logging enabled" do
        ###   let(:params) {{
        ###     :enable_logging => true,
        ###   }}
        ###   ###it_behaves_like "a structured module"
        ###   it { is_expected.to contain_class('foreman::config::logging') }
        ###   it { is_expected.to contain_class('foreman::config::logging').that_comes_before('foreman::service') }
        ###   it { is_expected.to create_notify('FIXME: logging') }
        ### end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'foreman class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('foreman') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
