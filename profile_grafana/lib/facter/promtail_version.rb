# Check if the binary is present
def binary_present?(binary)
    Facter::Core::Execution.which(binary)
end

# Only run the fact if the binary is present
if binary_present?('/usr/local/bin/promtail')
    Facter.add('promtail_version') do
        setcode do
            promtail_version = Facter::Core::Execution.execute('sudo -u promtail /usr/local/bin/promtail --version 2>&1 | grep "version " | cut -d " " -f 3')
            Facter.debug("Promtail version from fact: #{promtail_version}")
            promtail_version.strip if $?.exitstatus == 0
        end
    end
end
