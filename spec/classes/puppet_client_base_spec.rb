require 'spec_helper'

describe 'puppet::client::base' do

  if (Gem::Version.new(PUPPETVERSION) > Gem::Version.new(2))
    agent = 'agent'
  else
    agent = 'puppetd'
  end

  OSES.each do |os|
    describe "When on #{os} with mysql" do
      let(:facts) { { :operatingsystem     => os,
                      :puppetversion       => PUPPETVERSION,
                      :puppet_server       => 'pm.example.com',
                      :puppet_reportserver => 'reports.example.com',
                      :puppet_environment  => 'someuser'
                  } } 

      it { should contain_package('facter').with_ensure('present') }
      it { should contain_package('puppet').with_ensure('present') }
      it do should contain_package('lsb-release').with(
	      'ensure' => 'present',
	      'name'   => VARS[os]['lsb_release']
      ) end

      it { should contain_user('puppet').with_ensure('present') }

      it { should contain_puppet__config('main/ssldir').with_value('/var/lib/puppet/ssl') }
      it { should contain_puppet__config("#{agent}/server").with_value('pm.example.com') }
      it { should contain_puppet__config("#{agent}/reportserver").with_value('reports.example.com') }
      it { should contain_puppet__config("#{agent}/report").with_value('true') }
      it { should contain_puppet__config("#{agent}/configtimeout").with_value('3600') }
      it { should contain_puppet__config("#{agent}/pluginsync").with_value('true') }
      it { should contain_puppet__config("#{agent}/plugindest").with_value('/var/lib/puppet/lib') }
      it { should contain_puppet__config("#{agent}/libdir").with_value('/var/lib/puppet/lib') }
      it { should contain_puppet__config("#{agent}/pidfile").with_value('/var/run/puppet/puppetd.pid') }
      it { should contain_puppet__config("#{agent}/environment").with_value('someuser') }
      it { should contain_puppet__config("#{agent}/diff_args").with_value('-u') }

      it { should_not contain_puppet__config("#{agent}/factsync") }
      it { should_not contain_puppet__config("#{agent}/environments") }
    end
  end
end
