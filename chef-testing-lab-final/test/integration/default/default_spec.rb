expected_timezone = attribute('expected_tz', {})

describe file('/etc/sysconfig/clock') do
    expected_content = %Q(ZONE="#{expected_timezone}"
UTC=true)
    it { should exist }
    it { should be_file }
    its('content') { should match(expected_content) }
end

describe file('/etc/localtime') do
    it { should exist }
    it { should be_file }
    it { should be_symlink }
    it { should be_linked_to("/usr/share/zoneinfo/#{expected_timezone}")}
end

describe service('ntpd') do
    it { should be_installed }
    it { should be_enabled }
end