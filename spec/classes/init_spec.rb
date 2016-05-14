require 'spec_helper'

describe 'foreman' do
  shared_examples_for "a structured module" do
    let(:precondition) {
      'include "::foreman"'
    }
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('foreman') }
    it { is_expected.to contain_class('foreman::params') }
  end

  shared_examples_for "a foreman installation" do
    let(:pre_condition) {
      'include "::foreman"'
    }

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
    it { is_expected.to contain_class('foreman::config::ssl') }

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
    it { is_expected.to contain_file("#{facts[:puppet_ruby_dir]}/reports/foreman.rb") }

    it { is_expected.to contain_foreman__user('admin') }
    it { is_expected.to contain_foreman_user('admin') }
    it { is_expected.to contain_foreman__rake('apipie:cache') }
    it { is_expected.to contain_foreman__rake('db:migrate') }
    it { is_expected.to contain_foreman__rake('db:seed') }

    it { is_expected.to contain_pki__copy('/etc/foreman') }
    it { is_expected.to contain_pki__copy("#{facts[:puppet_vardir]}/simp") }
    it { is_expected.to contain_pupmod__conf('foreman-reports') }
    it { is_expected.to contain_postgresql__server__db('foreman') }
    it { is_expected.to contain_pam__access__manage('foreman') }
  end

  shared_examples_for "a foreman/passenger installation" do
    let(:precondition) {
      'include "::foreman"'
    }
    it { is_expected.to contain_class('foreman::passenger') }
    it { is_expected.to contain_apache__add_site('05-foreman') }
    it { is_expected.to contain_apache__add_site('05-foreman-ssl') }
    it { is_expected.to contain_apache__add_site('foreman_passenger') }
    it { is_expected.to contain_file('/var/run/passenger') }
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts[:puppet_ruby_dir] = '/var/lib/ruby/gems/puppet'
          facts[:puppet_vardir] = '/var/lib/puppet'

          facts
        end

        context "foreman class without any parameters" do
          let(:params) {{ }}
          it_behaves_like "a structured module"
          it_behaves_like "a foreman installation"
          it_behaves_like "a foreman/passenger installation"
          it { is_expected.to contain_foreman_smart_proxy('foo')}
          it { is_expected.to contain_foreman__smart_proxy('foo')}
          it { is_expected.to contain_file('/etc/foreman-proxy/ssl/certs/foo.example.com.pem') }
          it { is_expected.to contain_file('/etc/foreman-proxy/ssl/private_keys/foo.example.com.pem') }
          it { is_expected.to contain_file('/etc/foreman/ssl/certs/foo.example.com.pem') }
          it { is_expected.to contain_file('/etc/foreman/ssl/private_keys/foo.example.com.pem') }
          it { is_expected.to contain_file('/etc/httpd/conf.d/05-foreman-ssl.d') }
          it { is_expected.to contain_file('/etc/httpd/conf.d/05-foreman.d') }
          it { is_expected.to contain_file('/etc/puppet/foreman.yaml') }
        end
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
