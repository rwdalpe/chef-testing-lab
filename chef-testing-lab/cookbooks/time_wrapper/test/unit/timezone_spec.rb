# These require statements are necessary for chefspec to work.
require 'chefspec'
# The chefspec/berkshelf requirement will have chefspec auto-resolve dependent
# cookbooks using the first Berksfile it finds (scanning up the directory tree)
require 'chefspec/berkshelf'

# Here we group our tests for a single recipe
# ChefSpec makes the name of the recipe available to tests inside this block
# under the `described_recipe` variable.
describe('time_wrapper::timezone') do
    # For these tests, we'll execute a ChefSpec convergence.
    # You'll notice that $DEFAULT_CENTOS_SOLORUNNER_CFG doesn't seem to be
    # defined anywhere. Take a look at `spec_helper.rb` and you'll see it's
    # definition. Remember that we pass the `--require ./spec_helper` to rspec
    # when we run our tests.
    let(:chef_run) { ChefSpec::SoloRunner.new($DEFAULT_CENTOS_SOLORUNNER_CFG).converge(described_recipe) }
    # This makes the node object from the convergence available to our tests for
    # examination.
    let(:node) { chef_run.node }

    # TODO:
    # Add a test which verifies the following:
    #  * The default attributes needed by time_wrapper::timezone have correct values
    #  * The node['tz'] and node['timezone']['use_symlink'] are correctly overridden
    #  * The timezone-ii::default recipe is included

    it('should test timezon-ii inclusion') do
        pending(%Q(Add a test which verifies the following:
* The default attributes needed by time_wrapper::timezone have correct values
* The node['tz'] and node['timezone']['use_symlink'] are correctly overridden
* The timezone-ii::default recipe is included))
    end

    # Here we describe our test
    it('should set /etc/sysconfig/clock with correct content') do
        # We expect the /etc/sysconfig/clock file to look a certain way
        expected_content=%Q(ZONE="#{node['wrapper']['time']['tz']}"
UTC=true)

        # And now we use some of ChefSpec's built in validation methods to
        # verify the file content is as we expect.
        expect(chef_run).to(
            render_file('/etc/sysconfig/clock')
                .with_content(expected_content))
    end
end