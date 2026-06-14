#!/bin/bash
# Получить токен
TOKEN=$(curl -s -X POST https://msk.cloud.vk.com/infra/identity/v3/auth/tokens \
  -H "Content-Type: application/json" \
  -d "{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"name\":\"$OS_USERNAME\",\"domain\":{\"name\":\"$OS_USER_DOMAIN_NAME\"},\"password\":\"$OS_PASSWORD\"}}},\"scope\":{\"project\":{\"id\":\"$OS_PROJECT_ID\"}}}}" \
  -i | grep "X-Subject-Token" | cut -d" " -f2- | tr -d '\r')

# Получить последний образ
IMAGE_ID=$(curl -s -H "X-Auth-Token: $TOKEN" \
  "https://infra.mail.ru:9292/v2/images?name=web-server-base&sort=created_at:desc&limit=1" | \
  python3 -c "import sys,json; data=json.load(sys.stdin); print(data['images'][0]['id'] if data['images'] else 'none')")

if [ "$IMAGE_ID" != "none" ]; then
  echo "image_name = \"$IMAGE_ID\"" > terraform/image.auto.tfvars
  echo "Found image: $IMAGE_ID"
else
  echo "No image found!"
fi