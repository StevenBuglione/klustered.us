# This script is used to create environment variables for the secrets read from 1password.
export AWS_ACCESS_KEY_ID=$(op read "op://klustered.us/axsbnpsxo3473ionuge2unpaju/access-key")
export AWS_SECRET_ACCESS_KEY=$(op read "op://klustered.us/axsbnpsxo3473ionuge2unpaju/secret-access-key")

op read "op://klustered.us/ci-ssh-key/private-key" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa