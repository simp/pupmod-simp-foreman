require 'spec_helper'

describe 'foreman' do
  shared_examples_for "a structured module" do
    it { is_expected.to compile.with_all_deps }
    ### it { is_expected.to create_class('foreman') }
    ### it { is_expected.to contain_class('foreman') }
    ### it { is_expected.to contain_class('foreman::params') }
    ### it { is_expected.to contain_class('foreman::install').that_comes_before('foreman::config') }
    ### it { is_expected.to contain_class('foreman::config') }
    ### it { is_expected.to contain_class('foreman::service').that_subscribes_to('foreman::config') }

    ### it { is_expected.to contain_service('foreman') }
    ### it { is_expected.to contain_package('foreman').with_ensure('present') }
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
