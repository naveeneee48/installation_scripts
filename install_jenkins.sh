# Jenkins Installation on Ubuntu Machine:

sudo apt update
sudo apt install fontconfig openjdk-17-jre -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update 
sudo apt-get install jenkins -y 

sudo apt install docker.io

sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl restart docker

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
