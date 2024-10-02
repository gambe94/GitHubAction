import pytest
import subprocess
import testinfra


@pytest.fixture(scope='session')
def host(request):
    # Build the Docker image
    subprocess.check_call(['docker', 'build', '-t', 'myimage', '.'])
    # Run a container in detached mode
    docker_id = subprocess.check_output(
        ['docker', 'run', '-it', '-d', 'myimage']).decode().strip()
    # Return a testinfra connection to the container
    yield testinfra.get_host("docker://" + docker_id)
    # At the end of the test suite, destroy the container
    subprocess.check_call(['docker', 'rm', '-f', docker_id])


@pytest.mark.usefixtures('host')
class TestSfAutomationImage:
    """Test class for the sf_automation Docker image."""

    def test_ubuntu_version(self, host):
        cmd = host.check_output('cat /etc/os-release')
        assert 'VERSION_ID="22.04"' in cmd

    def test_passwd_file(self, host):
        passwd = host.file("/etc/passwd")
        assert passwd.contains('root')
        assert passwd.user == 'root'
        assert passwd.group == 'root'
        assert passwd.mode == 0o644

        # Check default shell for sfautomation user
        assert passwd.contains('sfautomation:/bin/bash')

    def test_sfautomation_user_is_set(self, host):
        # Assert that the user is set to 'sfautomation'
        assert host.user().name == 'sfautomation'
        assert host.user().home == '/home/sfautomation'

    def test_sf_cli_installed(self, host):
        # Check if 'sf' command is available
        assert host.exists('sf')
        result = host.run('sf --version')
        assert '@salesforce/cli' in result.stdout

    def test_python_installed(self, host):
        # Check if Python is installed
        assert host.exists('python3')
        result = host.run('python3 --version')
        assert 'Python 3' in result.stdout

    def test_node_installed(self, host):
        # Check if Node.js is installed
        assert host.exists('node')
        result = host.run('node --version')
        assert 'v' in result.stdout  # Node.js version starts with 'v'

    def test_npm_installed(self, host):
        # Check if npm is installed
        assert host.exists('npm')
        result = host.run('npm --version')
        assert result.rc == 0  # Ensure npm command runs successfully