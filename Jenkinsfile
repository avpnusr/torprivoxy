pipeline {
  agent any
  stages {
    stage('Checkout SCM') {
      steps {
        git(url: 'https://git.khmls.net/klein/torprivoxy.git', branch: 'master', credentialsId: '84da4d3d-4d74-40d4-8ebb-234743939799')
        dir(path: './torprivoxy')
      }
    }

    stage('Build Docker-Container') {
      steps {
        sh '''#!/usr/bin/env bash
set -Eeuo pipefail


echo "Creating buildx builder instance..."
BDXNAME="$(docker buildx create --use)"

cleanup() {
    docker buildx rm "$BDXNAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker buildx build \\ 
    --platform=linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \\
    -t git.khmls.net/klein/torprivoxy:latest \\
    --push -f Dockerfile .

sleep 5

docker buildx build \\ 
    --platform=linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \\
    -t git.khmls.net/klein/torprivoxy:latest-debian \\
    --push -f Dockerfile.debian .

echo "Build and push complete, deleting builder instance..."
docker buildx rm "$BDXNAME"'''
      }
    }

    stage('Cleanup') {
      steps {
        cleanWs()
      }
    }

  }
  environment {
    GO_VERSION = '1.26'
  }
}