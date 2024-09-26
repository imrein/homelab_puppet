# Check if the binary is present
def binary_present?(binary)
    Facter::Core::Execution.which(binary)
end

# Only run the fact if the binary is present
if binary_present?('/usr/local/bin/prometheus')
    Facter.add('prometheus_version') do
        setcode do
            prometheus_version = Facter::Core::Execution.execute('sudo -u prometheus /usr/local/bin/prometheus --version 2>&1 | grep "version " | cut -d " " -f 3')
            Facter.debug("Prometheus version from fact: #{prometheus_version}")
            prometheus_version.strip if $?.exitstatus == 0
        end
    end
end
