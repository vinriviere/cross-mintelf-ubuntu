#!/bin/bash -eu
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.

# This installs a GnuPG private/public key pair on the build system,
# so gpg can sign the source packages.

# Our private key is the critical security component, it must remain secret.
# We store it as GPG_KEYS repository secret in GitHub's project settings. It
# is passed to this script as an environment variable by GitHub Actions.
# As environment variables can only contain text, our key files are transformed
# like this: tar, xz, base64. Then they can be decoded here. This is safe as
# GitHub Actions never shows the contents of secure variables.

# To generate the contents of the GPG_KEYS variable:
# Be sure to be in an empty, temporary directory.
#
# Generate a new key pair, with empty passphrase.
# gpg --homedir . --gen-key
#
# Export the resulting private/public key
# gpg --homedir . --export-secret-key --armor | xz | base64 -w 0
#
# Select the resulting encoded text (several lines) to copy it to the clipboard.
# Then go to the GitHub project settings:
# https://github.com/vinriviere/cross-mintelf-ubuntu/settings/secrets/actions
# Create a new repository secret named GPG_KEYS, and paste the value.
# The script below will recreate the key files from that variable contents.

if [ -z ${GPG_KEYS+x} ]
then
  echo "error: GPG_KEYS is undefined" >&2
  exit 1
fi

echo $GPG_KEYS | base64 -d | unxz | gpg --import

# Ultimately trust our own public key
# This avoids warnings with dput
MY_PUBKEY_ID=$(gpg --list-secret-keys --keyid-format short | sed -n 's|^sec *[^/]*/\([^ ]*\).*|\1|p')
MY_PUBKEY_FINGERPRINT=$(LANG= gpg --fingerprint $MY_PUBKEY_ID | sed -n '2 p' | sed 's/ //g')
echo $MY_PUBKEY_FINGERPRINT:6: | gpg --import-ownertrust

# Display our key details and trust level
gpg --export-ownertrust
