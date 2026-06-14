#!/bin/bash
# Получить ID последнего образа Packer
IMAGE_ID=$(openstack image list -f value -c ID -c Name | grep web-server-base | sort -k2 | tail -1 | awk '{print $1}')

if [ -z "$IMAGE_ID" ]; then
  echo "Образ не найден!"
else
  echo "Найден образ: $IMAGE_ID"
  echo "image_name = \"$IMAGE_ID\"" > image.auto.tfvars
fi