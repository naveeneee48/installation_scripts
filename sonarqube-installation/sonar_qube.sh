#!/bin/bash

# Step 1: Install required dependencies
echo "Installing required dependencies..."
sudo apt update
sudo apt install -y openjdk-17-jre wget unzip git curl

# Step 2: Install SonarQube
SONAR_VERSION="9.9.0.65466"
SONAR_HOME="/opt/sonarqube"

echo "Downloading SonarQube version $SONAR_VERSION..."
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip -P /tmp/

echo "Extracting SonarQube..."
sudo unzip /tmp/sonarqube-$SONAR_VERSION.zip -d /opt/
sudo mv /opt/sonarqube-$SONAR_VERSION /opt/sonarqube

# Step 3: Set ownership and permissions
echo "Setting up SonarQube permissions..."
sudo chown -R $USER:$USER $SONAR_HOME
sudo chmod -R 755 $SONAR_HOME

# Step 4: Configure SonarQube to run as a service
echo "Creating SonarQube systemd service..."
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOL
[Unit]
Description=SonarQube
Documentation=http://www.sonarqube.org/
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=$SONAR_HOME/bin/linux-x86-64/sonar.sh start
ExecStop=$SONAR_HOME/bin/linux-x86-64/sonar.sh stop
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOL

# Step 5: Start SonarQube service
echo "Starting SonarQube..."
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

# Step 6: Install SonarQube Scanner
echo "Installing SonarQube Scanner..."
SONAR_SCANNER_VERSION="6.0.0.4432"
SONAR_SCANNER_HOME="/opt/sonar-scanner"

# if you want other version of sonar-scanner please check it out this website https://binaries.sonarsource.com/?prefix=Distribution/sonar-scanner-cli/


wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip -P /tmp/
sudo unzip /tmp/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip -d /opt/
sudo mv /opt/sonar-scanner-$SONAR_SCANNER_VERSION-linux /opt/sonar-scanner

# Step 7: Set up environment variables for SonarQube Scanner
echo "Setting up environment variables for SonarQube Scanner..."
echo "export SONAR_SCANNER_HOME=$SONAR_SCANNER_HOME" >> ~/.bashrc
echo "export PATH=\$PATH:\$SONAR_SCANNER_HOME/bin" >> ~/.bashrc
source ~/.bashrc

# Step 8: Clone the Git repository and configure SonarQube analysis
echo "Cloning the Git repository..."
#git clone git@10.4.0.1:Wellspring_Systems/cyberdata.git

# Step 9: Configure the SonarQube project for the Git repository
cd ~/gitea/cyberblitz-agent

echo "Creating sonar-project.properties..."
cat <<EOL > sonar-project.properties
sonar.projectKey=cyberblitz-agent
sonar.projectName=cyberblitz-agent
sonar.projectVersion=1.0
sonar.sources=.
sonar.host.url=http://localhost:9000
sonar.login=<< go to sonarqube UI > Administration > security > users > generate_token >>
EOL

# Step 10: Run the SonarQube Scanner analysis
echo "Running SonarQube analysis..."
echo "go to the particular git folder check the sonar-project.properties once then run 'sonar-scanner'"
sonar-scanner

# Step 11: Check SonarQube dashboard
echo "SonarQube analysis complete. Visit http://localhost:9000 to check the dashboard."

