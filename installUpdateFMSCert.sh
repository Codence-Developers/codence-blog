#!/bin/sh

# Usage message
usage() { echo "Usage: $0 [-h hostname] [-u fms_user] [-u fms_password]"; exit 1; }

# Get options
while getopts ":h:u:p:" option; do
  case $option in
    h)
      FQDN="$OPTARG"
      ;;
    u)
      FMS_USER="$OPTARG"
      ;;
    p)
      FMS_PASS="$OPTARG"
      ;;
    *)
      usage
      ;;
  esac
done

# Check that required options have values
if [ -z $FQDN ] || [ -z $FMS_USER ] || [ -z $FMS_PASS ]; then
  usage
fi

# Download the SSL automation script
wget 'https://raw.githubusercontent.com/Codence-Developers/codence-blog/main/updateFMSCert.sh' -O /root/updateFMSCert.sh

# Update the SSL automation script variables with the required options
sed -i "s/FQDN=\"\"/FQDN=\"$FQDN\"/g" /root/updateFMSCert.sh
sed -i "s/FMS_USER=\"\"/FMS_USER=\"$FMS_USER\"/g" /root/updateFMSCert.sh
sed -i "s/FMS_PASS=\"\"/FMS_PASS=\"$FMS_PASS\"/g" /root/updateFMSCert.sh

# Make the SSL automation script executable

chmod +x /root/updateFMSCert.sh

# Create the crontab schedule to run the script
echo "0 3 * * * /root/updateFMSCert.sh" | crontab -

# Create the post-deploy script and make executable
echo "touch /home/ubuntu/sslDeploy_true" > /etc/letsencrypt/renewal-hooks/deploy/createDeployFlag
echo "chmod 777 /home/ubuntu/sslDeploy_true" >> /etc/letsencrypt/renewal-hooks/deploy/createDeployFlag
chmod +x /etc/letsencrypt/renewal-hooks/deploy/createDeployFlag