export LEANSW_DOCKER_REGISTRY=registry.cn-hangzhou.aliyuncs.com/leansw
export IMAGE_FROM=$LEANSW_DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:rc-$RC_LABEL
docker pull $IMAGE_FROM

IMAGE_RELEASE_VERSION=$LEANSW_DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:release-$GO_PIPELINE_LABEL
IMAGE_RELEASE=$LEANSW_DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:release


echo "begin generate Dockerfile"
source $HOME/.bashrc
source "$HOME/.jenv/bin/jenv-init.sh"
jenv use java 1.8.0_71

echo "
from ${IMAGE_FROM}
LABEL go.release.trigger.user=${GO_TRIGGER_USER}
LABEL go.release.pipeline.name=${GO_PIPELINE_NAME}
LABEL go.release.pipeline.label=${GO_PIPELINE_LABEL}
LABEL go.stage=release
" > Dockerfile.tmp


LABEL go.dev.trigger.user=${GO_TRIGGER_USER}

echo "generated Dockerfile:"
echo "============================"
cat Dockerfile.tmp
echo "============================"

docker build -f Dockerfile.tmp -t  $IMAGE_RELEASE_VERSION .
rm Dockerfile.tmp
docker rmi $IMAGE_FROM


docker tag $IMAGE_RELEASE_VERSION $IMAGE_RELEASE
docker push $IMAGE_RELEASE
docker rmi $IMAGE_RELEASE

docker push $IMAGE_RELEASE_VERSION
docker rmi $IMAGE_RELEASE_VERSION