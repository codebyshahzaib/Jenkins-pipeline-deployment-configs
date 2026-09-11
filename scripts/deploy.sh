#!/usr/bin/env bash
set -euo pipefail

: "${IMAGE:?Set IMAGE, for example dockerhub-user/dummy-deployment-app}"
: "${IMAGE_TAG:=latest}"
: "${EC2_HOST:?Set EC2_HOST to the public EC2 address}"
: "${SSH_KEY:?Set SSH_KEY to the EC2 private key path}"
: "${EC2_USER:=ubuntu}"

ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$EC2_USER@$EC2_HOST" \
  "sudo docker pull $IMAGE:$IMAGE_TAG && \\
   (sudo docker rm -f dummy-deployment-app || true) && \\
   sudo docker run -d --restart unless-stopped --name dummy-deployment-app -p 80:8080 $IMAGE:$IMAGE_TAG"