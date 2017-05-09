expected_timezone = attribute("expected_tz", {})

describe ("/etc/sysconfig/clock tests") do
    it("should have correct content") do
        f = file("/etc/sysconfig/clock")
        expected_content = %Q(ZONE="#{expected_timezone}"
UTC=true)
        expect(f).to(exist())
        expect(f).to(be_file())
        expect(f.content).to(match(expected_content))
    end
end

describe("/etc/localtime tests") do
    it("Should set up /etc/localtime correctly") do
        f = file("/etc/localtime")
        expect(f).to(exist())
        expect(f).to(be_file())
        expect(f).to(be_symlink())
        expect(f).to(be_linked_to("/usr/share/zoneinfo/#{expected_timezone}"))
    end
end

describe("ntpd service") do
    it("should be installed and enabled") do
        s = service("ntpd")
        expect(s).to(be_installed())
        expect(s).to(be_enabled())
    end
end