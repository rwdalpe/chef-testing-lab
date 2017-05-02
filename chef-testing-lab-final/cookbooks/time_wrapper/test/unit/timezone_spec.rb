require 'chefspec'
require 'chefspec/berkshelf'

describe('time_wrapper::timezone') do
    let(:chef_run) { ChefSpec::SoloRunner.new($DEFAULT_CENTOS_SOLORUNNER_CFG).converge(described_recipe) }
    let(:node) { chef_run.node }

    it('should override timezone-ii attributes and include timezone-ii') do
        expect(node['wrapper']['time']['tz']).to(eq('US/Pacific'))
        expect(node['tz']).to(eq(node['wrapper']['time']['tz']))
        expect(node['timezone']['use_symlink']).to(eq(true))
        expect(chef_run).to(include_recipe('timezone-ii::default'))
    end

    it('should set /etc/sysconfig/clock with correct content') do
        expected_content=%Q(ZONE="#{node['wrapper']['time']['tz']}"
UTC=true)

        expect(chef_run).to(
            render_file('/etc/sysconfig/clock')
                .with_content(expected_content))
    end
end