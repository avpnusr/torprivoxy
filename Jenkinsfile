pipeline {
  agent any

  triggers {
    cron('0 17 * * 0')
  }

  environment {
    IMAGE_GITEA = 'git.khmls.net/klein/torprivoxy'
    GITEA_HOST = 'git.khmls.net'
    GITEA_HOST_IP = '192.168.70.200'
    GITEA_CREDENTIALS_ID = '84da4d3d-4d74-40d4-8ebb-234743939799'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build and Push Images') {
      steps {
        script {
          if (env.GITEA_CREDENTIALS_ID?.trim()) {
            withCredentials([usernamePassword(credentialsId: env.GITEA_CREDENTIALS_ID, usernameVariable: 'GITEA_USERNAME', passwordVariable: 'GITEA_TOKEN')]) {
              sh '''#!/usr/bin/env bash
set -Eeuo pipefail
echo "$GITEA_TOKEN" | docker login "$GITEA_HOST" -u "$GITEA_USERNAME" --password-stdin
'''
            }
          } else {
            echo 'Skipping Gitea login: GITEA_CREDENTIALS_ID is empty.'
          }
        }

        sh '''
#!/usr/bin/env bash
set -Eeuo pipefail

docker run --privileged --rm tonistiigi/binfmt --install all || true

echo "Creating buildx builder instance..."
BUILDX_CFG="$(mktemp)"
cat > "$BUILDX_CFG" <<EOF
[registry."$GITEA_HOST"]
  mirrors = ["$GITEA_HOST_IP"]
EOF
BDXNAME="$(docker buildx create --use --driver-opt network=host --config "$BUILDX_CFG")"

cleanup() {
    docker buildx rm "$BDXNAME" >/dev/null 2>&1 || true
    rm -f "$BUILDX_CFG"
}
trap cleanup EXIT

docker buildx build \\
    --add-host "$GITEA_HOST:$GITEA_HOST_IP" \\
    --platform=linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \\
    -t "$IMAGE_GITEA:latest" \\
    --push -f Dockerfile .

sleep 5

docker buildx build \\
    --add-host "$GITEA_HOST:$GITEA_HOST_IP" \\
    --platform=linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \\
    -t "$IMAGE_GITEA:latest-debian" \\
    --push -f Dockerfile.debian .

echo "Build and push complete, deleting builder instance..."
'''
      }
    }

    stage('Cleanup') {
      steps {
        cleanWs()
      }
    }

  }
}