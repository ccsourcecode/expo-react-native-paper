#!/bin/bash
set -e

echo "Fixing OpenSSL configuration for Ruby..."

# Install OpenSSL 3
brew install openssl@3

# Set OpenSSL 3 environment variables
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
export PATH="$(brew --prefix openssl@3)/bin:$PATH"
export LDFLAGS="-L$(brew --prefix openssl@3)/lib"
export CPPFLAGS="-I$(brew --prefix openssl@3)/include"
export PKG_CONFIG_PATH="$(brew --prefix openssl@3)/lib/pkgconfig"

# Configure rbenv to use these options for future Ruby installations
if [ -d "$HOME/.rbenv" ]; then
  mkdir -p "$HOME/.rbenv/vars"
  echo "export RUBY_CONFIGURE_OPTS=\"--with-openssl-dir=\$(brew --prefix openssl@3)\"" > "$HOME/.rbenv/vars/openssl.sh"
  chmod +x "$HOME/.rbenv/vars/openssl.sh"
  echo "Configured rbenv to use OpenSSL 3 for Ruby installations"
fi

# Run c_rehash to update certificate links
echo "Updating OpenSSL certificate links..."
"$(brew --prefix openssl@3)/bin/c_rehash"

# Ensure OpenSSL 3 is functioning correctly
echo "Testing OpenSSL 3 installation..."
openssl version

echo "OpenSSL fix completed successfully" 