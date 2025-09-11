#!/bin/bash

set -eu

PROFILE="iac_learning"
ACCOUNT_ID=$(aws --profile $PROFILE sts get-caller-identity --query Account --output text)
REGION="ap-northeast-1"
REPO="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/hands-on-app"

aws --profile $PROFILE ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

docker buildx create --use || true
docker buildx build \
  --platform linux/amd64 \
  -t "${REPO}:latest" \
  ./app \
  --push
