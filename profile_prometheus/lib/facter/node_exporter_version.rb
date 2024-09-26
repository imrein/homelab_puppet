# Check if the binary is present
def binary_present?(binary)
    Facter::Core::Execution.which(binary)
end

# Only run the fact if the binary is present
if binary_present?('/usr/local/bin/node_exporter')
    Facter.add('node_exporter_version') do
        setcode do
            node_exporter_version = Facter::Core::Execution.execute('sudo -u node_exporter /usr/local/bin/node_exporter --version 2>&1 | grep "version " | cut -d " " -f 3')
            Facter.debug("Node_exporter version from fact: #{node_exporter_version}")
            node_exporter_version.strip if $?.exitstatus == 0
        end
    end
end
