# Unfortunately, Inspec requires you to define any attributes you expect to use
# during a test run. (remember these are provided values externally)
expected_timezone = attribute('expected_tz', {})

# We use an rspec-like syntax to write our tests.
# Here we describe a file
describe file('/etc/sysconfig/clock') do
    # We expect it to have some certain content, depending on our test attribute
    expected_content = %Q(ZONE="#{expected_timezone}"
UTC=true)
    # followed by some additional matchers
    it { should exist }
    it { should be_file }
    its('content') { should match(expected_content) }
end

# TODO:
# Add a test which verifies the following:
#  * /etc/localtime
#    * exists
#    * is a file
#    * is a symlink
#    * is symlinked to the expected timezone file in /usr/share/zoneinfo

describe('test /etc/localtime') do
    pending(%Q(Write a test which verifies
/etc/localtime 
* exists, 
* is a file, 
* is a symlink, 
* and is symlinked to the expected timezone file in /usr/share/zoneinfo))
end

# Here we describe a service and its expected state
describe service('ntpd') do
    it { should be_installed }
    it { should be_enabled }
end