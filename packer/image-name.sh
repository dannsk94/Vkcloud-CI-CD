#!/bin/bash
TOKEN=$(curl -s -X POST https://msk.cloud.vk.com/infra/identity/v3/auth/tokens \
  -H "Content-Type: application/json" \
  -d "{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"name\":\"$OS_USERNAME\",\"domain\":{\"name\":\"$OS_USER_DOMAIN_NAME\"},\"password\":\"$OS_PASSWORD\"}}},\"scope\":{\"project\":{\"id\":\"$OS_PROJECT_ID\"}}}}" \
  -i | grep "X-Subject-Token" | cut -d" " -f2- | tr -d '\r')

IMAGE_ID=$(curl -s -H "X-Auth-Token: $TOKEN" \
  "https://infra.mail.ru:9292/v2/images?name=web-server-base&sort=created_at:desc&limit=1" | \
  grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "image_name = \"$IMAGE_ID\"" > terraform/image.auto.tfvars
echo "Found image: $IMAGE_ID"