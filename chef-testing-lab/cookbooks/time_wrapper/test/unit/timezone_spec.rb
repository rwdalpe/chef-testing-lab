require 'chefspec'

describe('time_wrapper::timezone') do
    let(:chef_run) { ChefSpec::SoloRunner.new($DEFAULT_CENTOS_SOLORUNNER_CFG).converge(described_recipe) }
    let(:node) { chef_run.node }

    # TODO:
    # Add a test which verifies the following:
    #  * The default attributes needed by time_wrapper::timezone have correct values
    #  * The node['tz'] and node['timezone']['use_symlink'] are correctly overridden
    #  * The timezone-ii::default recipe is included

    it('should set /etc/sysconfig/clock with correct content') do
        expected_content=%Q(ZONE="#{node['wrapper']['time']['tz']}"
UTC=true)

        expect(chef_run).to(
            render_file('/etc/sysconfig/clock')
                .with_content(expected_content))
    end
end