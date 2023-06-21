#!/bin/sh

# Download the SSL automation script and make executable
wget 'https://raw.githubusercontent.com/Codence-Developers/codence-blog/main/updateFMSCert.sh' -O /root/updateFMSCert.sh
chmod +x /root/updateFMSCert.sh

# Create the crontab schedule to run the script
echo "0 3 * * * /root/updateFMSCert.sh" | crontab -

# Create the post-deploy script and make executable
echo "touch /home/ubuntu/sslDeploy_true" > /etc/letsencrypt/renewal-hooks/deploy/createDeployFlag
echo "chmod 777 /home/ubuntu/sslDeploy_true" >> /etc/letsencrypt/renewal-hooks/deploy/createDeployFlag
chmod +x /etc/letsencrypt/renewal-hooks/deploy/createDeployFlag

# Display configuration message
echo
echo
echo "You MUST update the user-defined variables in /root/updateFMSCert.sh with the values for this server."