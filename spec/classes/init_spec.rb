require 'spec_helper'

describe 'cognos' do

  context 'on CentOS 7' do
    describe 'without any parameters' do
      let(:facts) {{
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS',
        :operatingsystemmajrelease => '7',
        :is_vagrant => 'true',
      }}
      let(:params) {{ }}

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('cognos::cm_db::db2') }
      it { is_expected.to contain_class('cognos::install::main') }
      it { is_expected.to contain_class('cognos::install::prep') }
      it { is_expected.to contain_class('cognos::install::prereqs') }
      it { is_expected.to contain_class('cognos::install::service') }
      it { is_expected.to contain_class('cognos::config') }

      it { is_expected.to contain_file('/home/db2inst1/create_cognos_db.sql') }
      it { is_expected.to contain_file('/opt/ibm/cognos/analytics/drivers/db2jcc.jar') }
      it { is_expected.to contain_file('/vagrant/cognos_11_installer.properties') }
      it { is_expected.to contain_file('/etc/systemd/system/cognos.service') }
      it { is_expected.to contain_concat__fragment('cogconfig_base_pre').with(
        { :target => '/opt/ibm/cognos/analytics/configuration/cogstartup.puppet.xml' }
      )}
      it { is_expected.to contain_concat__fragment('cogconfig_base_post').with(
        { :target => '/opt/ibm/cognos/analytics/configuration/cogstartup.puppet.xml' }
      )}
      it { is_expected.to contain_concat__fragment('auth_provider_cognos_1').with(
        { :target => '/opt/ibm/cognos/analytics/configuration/cogstartup.puppet.xml' }
      )}
      it { is_expected.to contain_file('/etc/cognos') }
      it { is_expected.to contain_file('/var/log/cognos') }
      it { is_expected.to contain_file('/var/log/cognos/common') }
      it { is_expected.to contain_file('/var/log/cognos/wlp') }

      it { is_expected.to contain_user('cognos') }
      it { is_expected.to contain_user('cog_db2') }
      it { is_expected.to contain_group('cognos') }
      it { is_expected.to contain_group('cog_db2') }

    end
  end

end

