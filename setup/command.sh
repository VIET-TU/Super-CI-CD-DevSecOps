# setup gitlab
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo apt-get install gitlab-ee=14.9.1-ee.0

# Configure a URL for your GitLab
vi /etc/gitlab/gitlab.rb 
external_url 'http://gitlab.viettu.vn'


# Set up docker and docker-compose
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker -v
docker-compose -v

# SQL server and Cloud beaver
mkdir -p /tools/sqlserver
cd /tools/sqlserver
vi docker-compose.yml
docker-compose -f docker-compose.sqlserver.yml up -d
docker-compose -f docker-compose.beaver.yml up -d
## Check
docker exec -it -u root sqlserver  /bin/bash
/opt/mssql-tools18/bin/sqlcmd -S localhost  -U sa -P Str0ngPa5sVvorcl -C




# Install Netcore 6
apt update -y && apt upgrade -y
apt install -y wget apt-transport-https software-properties-common
wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt update -y && apt install -y dotnet-sdk-6.0
dotnet --version


# Install node 18
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt install nodejs -y


# Setup Gitlab-runner
apt update -y
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
apt install gitlab-runner
## Register runner
gitlab-runner register

# Setup permision
visudo
gitlab-runner ALL=(ALL:ALL) NOPASSWD: ALL
usermod -aG docker gitlab-runner
usermod -aG docker onlineshop

# Setup registry portus

## Install ansible
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

## Install awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

## Install terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor |  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform

## create key gen
ssh-keygen -t rsa
ssh-copy-id root@192.168.xxx.xxx

## Apply
terraform init
terraform apply --var-file "terraform.tfvars"

# Setup  aranchi
docker run --network host -d -p 222:22 -p 7331:7331 -p 9292:9292 --name arachni arachni/arachni:latest

## Use Aranchni CLI on deamon
wget https://github.com/Arachni/arachni/releases/download/v1.4/arachni-1.4-0.5.10-linux-x86_64.tar.gz
tar -xvf arachni-1.4xxx.tar.gz
### test
bin/arachni --output-verbose --scope-include http://192.168.254.203 --report-save-path=/tmp/online-shop-frontend.afr
bin/arachni_reporter /tmp/online-shop-frontend.afr --report=html:outfile=/tmp/online-shop-frontend.html.zip

## Use Use Aranchni CLI on container
docker build --network host -t viettu123/arachni:v1.4-0.5.10 .
### Test
docker run --rm -v /tmp/:/tmp/ viettu123/arachni:v1.4-0.5.10 bin/arachni --output-verbose --scope-include-subdomains http://192.168.254.203 --report-save-path=/tmp/online-shop-frontend.afr > /dev/null 2>&1
docker run --rm -v /tmp/:/tmp/ devopseduvn/arachni:v1.4-0.5.10 /bin/arachni_reporter /tmp/online-shop-frontend.afr --report=html:outfile=/tmp/online-shop-frontend.html.zip


# Install k6
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

## Test on deamon
k6 run -u 100 -d 20s login-test.js

# Test k6 on container
docker run --rm -v $(pwd)/performace_testing_script:/performace_testing_script loadimpact/k6 run -e RESULTS_PATH=/performace_testing_script --summary-export=/performace_testing_script/summary_perf.json /performace_testing_script/smoke-test.js
cat ./performace_testing_script/summary_perf.json | jq -r '["metric", "avg", "min", "med", "max", "p(90)", "p(95)"], (.metrics | to_entries[] | [.key, .value.avg, .value.min, .value.med, .value.max, .value["p(90)"], .value["p(95)"]]) | @csv' > $K6_PERFORMACE_TEST_REPORT.csv


# Set up report on telegram


# Set up ansible clear reresouce