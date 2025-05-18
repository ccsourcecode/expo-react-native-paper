#!/bin/bash
set -e

echo "Configuring macOS environment to prevent OpenSSL 1.1 installation attempts..."

# Pre-install openssl@3 to prevent dependencies from trying to install openssl@1.1
echo "Pre-installing OpenSSL 3 to prevent dependency issues..."
brew install openssl@3

# Create a .ruby-build-rc file to force rbenv to use OpenSSL 3
echo "Configuring rbenv to use OpenSSL 3..."
mkdir -p ~/.rbenv
cat > ~/.rbenv/ruby-build-rc << 'EOL'
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
EOL

# Create a hook to override RUBY_CONFIGURE_OPTS during rbenv install
mkdir -p ~/.rbenv/hooks
cat > ~/.rbenv/hooks/pre-install << 'EOL'
#!/bin/bash
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
echo "Using OpenSSL 3 from $(brew --prefix openssl@3) for Ruby installation"
EOL
chmod +x ~/.rbenv/hooks/pre-install

# Export OpenSSL 3 environment variables
export PATH="$(brew --prefix openssl@3)/bin:$PATH"
export LDFLAGS="-L$(brew --prefix openssl@3)/lib"
export CPPFLAGS="-I$(brew --prefix openssl@3)/include"
export PKG_CONFIG_PATH="$(brew --prefix openssl@3)/lib/pkgconfig"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"

# Add these to the various shell config files
echo 'export PATH="$(brew --prefix openssl@3)/bin:$PATH"' >> ~/.bash_profile
echo 'export LDFLAGS="-L$(brew --prefix openssl@3)/lib"' >> ~/.bash_profile
echo 'export CPPFLAGS="-I$(brew --prefix openssl@3)/include"' >> ~/.bash_profile
echo 'export PKG_CONFIG_PATH="$(brew --prefix openssl@3)/lib/pkgconfig"' >> ~/.bash_profile
echo 'export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"' >> ~/.bash_profile

# Check if any Gemfile references that might need openssl
if [ -f "Gemfile" ]; then
  echo "Checking Gemfile for OpenSSL dependencies..."
  if grep -q "openssl" Gemfile; then
    echo "Found OpenSSL references in Gemfile, updating to use OpenSSL 3"
    sed -i.bak 's/openssl.*1\.1.*/openssl (~> 3.0)/g' Gemfile
  fi
fi

# Override ruby-build to use OpenSSL 3
if [ -d "$HOME/.rbenv/plugins/ruby-build" ]; then
  echo "Patching ruby-build to use OpenSSL 3..."
  cd "$HOME/.rbenv/plugins/ruby-build"
  
  # Create a backup of the original file
  if [ -f share/ruby-build/3.0.0 ]; then
    cp share/ruby-build/3.0.0 share/ruby-build/3.0.0.bak
    
    # Replace openssl-1.1.1 with openssl-3 in the ruby-build definition
    sed -i.bak 's/openssl-1\.1\.1[a-z]*/openssl-3.0.12/g' share/ruby-build/3.0.0
    
    echo "Ruby 3.0.0 build definition updated to use OpenSSL 3"
  fi
fi

echo "OpenSSL configuration complete" 