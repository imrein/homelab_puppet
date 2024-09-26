# Check if the binary is present
def binary_present?(binary)
    Facter::Core::Execution.which(binary)
end

# Only run the fact if the binary is present
if binary_present?('/usr/local/bin/gitea')
    Facter.add('gitea_version') do
        setcode do
            gitea_version = Facter::Core::Execution.execute('sudo -u git /usr/local/bin/gitea --version 2>&1 | grep "version " | cut -d " " -f 3')
            Facter.debug("Gitea version from fact: #{gitea_version}")
            gitea_version.strip if $?.exitstatus == 0
        end
    end
end
