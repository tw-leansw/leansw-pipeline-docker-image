export LEANSW_DOCKER_REGISTRY=registry.cn-hangzhou.aliyuncs.com/leansw
IMAGE_FROM=leansw/${DOCKER_IMAGE_NAME}
docker rmi ${IMAGE_FROM}:bak
docker tag ${IMAGE_FROM} ${IMAGE_FROM}:bak
mkdir docker_tmp
cd docker_tmp

echo "begin generate Dockerfile"
source $HOME/.bashrc
source "$HOME/.jenv/bin/jenv-init.sh"
jenv use java 1.8.0_71

echo "GO_TRIGGER_USER"
echo $GO_TRIGGER_USER


echo ```
FROM ${IMAGE_FROM}
LABEL go.dev.trigger.user=${GO_TRIGGER_USER}
LABEL go.dev.pipeline.name=${GO_PIPELINE_NAME}
LABEL go.dev.pipeline.label=${GO_PIPELINE_LABEL}
LABEL go.dev.revision=${GO_REVISION}
LABEL go.dev.to.revision=${GO_TO_REVISION}
LABEL go.dev.from.revision=${GO_FROM_REVISION}
LABEL go.stage=dev
``` > Dockerfile.tmp

echo "generated Dockerfile:"
echo "============================"
cat Dockerfile.tmp
echo "============================"
IMAGE_BUILD=$LEANSW_DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$GO_PIPELINE_LABEL
docker build -f Dockerfile.tmp -t  $IMAGE_BUILD .

docker rmi  $IMAGE_FROM

docker tag $IMAGE_BUILD $LEANSW_DOCKER_REGISTRY/$DOCKER_IMAGE_NAME
rm Dockerfile.tmp

cd ..

rm -rf docker_tmp

docker push $LEANSW_DOCKER_REGISTRY/$DOCKER_IMAGE_NAME
docker rmi  $LEANSW_DOCKER_REGISTRY/$DOCKER_IMAGE_NAME

docker push $IMAGE_BUILD
docker rmi $IMAGE_BUILD
