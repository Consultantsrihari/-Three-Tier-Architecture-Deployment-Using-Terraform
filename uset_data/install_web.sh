#!/bin/bash -xe
# Exit on error (-e) and print commands (-x)

# Update packages and install Apache (httpd for Amazon Linux 2)
sudo yum update -y
sudo yum install -y httpd

# Start and enable Apache service
sudo systemctl start httpd
sudo systemctl enable httpd

# Create a simple placeholder web page
# Use `hostname -f` to display the instance ID serving the request
echo "<html><head><title>3-Tier App</title></head><body><h1>Welcome to the AWS 3-Tier Architecture Demo!</h1><p>Served by instance: $(hostname -f)</p></body></html>" | sudo tee /var/www/html/index.html > /dev/null

# Set correct permissions for web root (if needed, usually okay by default)
# sudo chown -R apache:apache /var/www/html

# Restart apache to ensure all configs are loaded (optional, start should be enough)
# sudo systemctl restart httpd

# Note: For a real application, you would:
# 1. Install necessary dependencies (PHP, Python, Node.js, Java runtime etc.)
# 2. Pull your application code (e.g., from Git, S3, CodeDeploy)
# 3. Configure the application (e.g., database connection strings - ideally fetched securely from Secrets Manager/Parameter Store via IAM role)
# 4. Configure Apache/Nginx to serve your application
# 5. Start your application server/process
