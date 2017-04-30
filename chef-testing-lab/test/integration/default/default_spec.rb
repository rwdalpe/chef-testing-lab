expected_timezone = attribute('expected_tz', {})

describe file('/etc/sysconfig/clock') do
    expected_content = %Q(ZONE="#{expected_timezone}"
UTC=true)
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

describe service('ntpd') do
    it { should be_installed }
    it { should be_enabled }
end