#!/bin/bash
set -e

echo "Configuring macOS environment to prevent OpenSSL 1.1 installation attempts..."

# Create an alias for brew that prevents openssl@1.1 installation
cat > ~/.brew_openssl_filter.sh << 'EOL'
#!/bin/bash
if [[ "$*" == *"openssl@1.1"* ]]; then
  echo "ERROR: Attempting to install deprecated openssl@1.1. Redirecting to openssl@3"
  modified_args="${@/openssl@1.1/openssl@3}"
  /usr/local/bin/brew $modified_args
else
  /usr/local/bin/brew "$@"
fi
EOL

chmod +x ~/.brew_openssl_filter.sh

# Create an alias for brew in the shell config
echo 'alias brew=~/.brew_openssl_filter.sh' >> ~/.bash_profile
echo 'alias brew=~/.brew_openssl_filter.sh' >> ~/.bashrc
echo 'alias brew=~/.brew_openssl_filter.sh' >> ~/.zshrc

# Source the updated profile in the current shell
source ~/.bash_profile 2>/dev/null || true
source ~/.bashrc 2>/dev/null || true
source ~/.zshrc 2>/dev/null || true

# Pre-install openssl@3 to prevent dependencies from trying to install openssl@1.1
echo "Pre-installing OpenSSL 3 to prevent dependency issues..."
/usr/local/bin/brew install openssl@3

# Export OpenSSL 3 environment variables
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@3/include"
export PKG_CONFIG_PATH="/usr/local/opt/openssl@3/lib/pkgconfig"

# Add these to the various shell config files
echo 'export PATH="/usr/local/opt/openssl@3/bin:$PATH"' >> ~/.bash_profile
echo 'export LDFLAGS="-L/usr/local/opt/openssl@3/lib"' >> ~/.bash_profile
echo 'export CPPFLAGS="-I/usr/local/opt/openssl@3/include"' >> ~/.bash_profile
echo 'export PKG_CONFIG_PATH="/usr/local/opt/openssl@3/lib/pkgconfig"' >> ~/.bash_profile

# Check if any Gemfile references that might need openssl
if [ -f "Gemfile" ]; then
  echo "Checking Gemfile for OpenSSL dependencies..."
  if grep -q "openssl" Gemfile; then
    echo "Found OpenSSL references in Gemfile, updating to use OpenSSL 3"
    sed -i.bak 's/openssl.*1\.1.*/openssl (~> 3.0)/g' Gemfile
  fi
fi

echo "OpenSSL configuration complete" 