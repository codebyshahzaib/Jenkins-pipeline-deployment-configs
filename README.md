# Jenkins Pipeline Deployment

This repository contains a dummy Flask service and a complete Docker-to-EC2 deployment path:

1. Jenkins validates and builds the image.
2. Jenkins pushes the image to Docker Hub.
3. Jenkins connects to EC2 over SSH, pulls the image, and runs it on port 80.

## Project files

- `app.py`: Flask service with `/` and `/health` endpoints.
- `Dockerfile`: production-style Gunicorn image.
- `Jenkinsfile`: build, push, and deploy pipeline.
- `terraform/`: provisions an Ubuntu EC2 instance and installs Docker through cloud-init.
- `scripts/deploy.sh`: manual deployment helper using the same remote commands as Jenkins.

## Run locally

```bash
docker build -t dummy-deployment-app .
docker run --rm -p 8080:8080 dummy-deployment-app
curl http://localhost:8080/health
```

## Provision EC2

Prerequisites: AWS credentials, Terraform, an existing EC2 key pair, and the public IP range that should be allowed to SSH.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: key_name and ssh_cidr are required.
terraform init
terraform plan
terraform apply
terraform output -raw ec2_public_ip
```

The instance uses Ubuntu 24.04, installs Docker automatically, permits HTTP on port 80, and restricts SSH to `ssh_cidr`. Do not use `0.0.0.0/0` for SSH in a real environment.

## Configure Jenkins

Create these Jenkins credentials and environment values:

- Username/password credential ID `dockerhub`, using a Docker Hub access token as the password.
- SSH private-key credential ID `ec2-ssh`, with username `ubuntu`.
- Global or job environment variable `DOCKERHUB_USERNAME`, set to the Docker Hub username.
- Global or job environment variable `EC2_HOST`, set to the Terraform `ec2_public_ip` output.

The Jenkins agent must have Docker and Python installed. Create a Pipeline job from this repository and run it with an `IMAGE_TAG` such as `1.0.${BUILD_NUMBER}`. The image repository is `${DOCKERHUB_USERNAME}/dummy-deployment-app`.

## Manual deployment

```bash
chmod +x scripts/deploy.sh
IMAGE=dockerhub-user/dummy-deployment-app \
IMAGE_TAG=latest \
EC2_HOST=203.0.113.20 \
SSH_KEY=~/.ssh/my-existing-ec2-key.pem \
./scripts/deploy.sh
```

Verify with `curl http://EC2_HOST/health`. To remove the infrastructure, run `terraform destroy` from `terraform/`.
