# Azure CI/CD Tutorial

간단한 Nginx 데모 이미지를 기반으로 정적 페이지(`index.html`)를 교체하여 Azure CI/CD 실습에 활용하는 예제입니다.

이 저장소의 핵심은 로컬에서 `Dockerfile`을 직접 실행하는 것이 아니라, GitHub Actions를 통해 이미지를 자동으로 빌드/푸시하고 Azure Web App(컨테이너)로 배포하는 완전 자동화 CI/CD 파이프라인입니다.

## 파이프라인 개요

- **트리거**: `main` 브랜치로 푸시 시 자동 실행 (수동 실행도 지원)
- **빌드/푸시**: `docker/build-push-action`으로 `linux/amd64` 이미지 빌드, Docker Hub에 `TIMESTAMP` 태그와 `latest`로 푸시
- **배포**: `azure/webapps-deploy@v3`를 사용해 Azure Web App(컨테이너)에 푸시된 이미지를 배포
- **동시성 보호**: 같은 브랜치에서 중복 실행 시 이전 작업 취소
- **워크플로 경로**: `.github/workflows/cicd.yml`

## 사전 준비

- **Azure Web App (Linux, Container)** 1개 (이름 예: `your-app-name`)
- **Docker Hub** 계정 및 리포지토리 (예: `<your-dockerhub-username>/hello-app`)
- **GitHub Secrets** 설정:
  - `DOCKERHUB_USERNAME`: Docker Hub 사용자명
  - `DOCKERHUB_TOKEN`: Docker Hub Access Token (write 권한)
  - `AZURE_WEBAPP_NAME`: App Service 이름
  - `AZURE_PUBLISH_PROFILE`: App Service Publish Profile XML 전체 내용

## 사용 방법 (CI/CD)

1. 리포지토리를 포크/클론합니다.
2. Docker Hub에 리포지토리(`hello-app`)를 준비합니다.
3. GitHub 리포지토리의 Settings → Secrets and variables → Actions에서 위의 시크릿 4개를 등록합니다.
4. 필요 시 `.github/workflows/cicd.yml`의 이미지 이름을 본인 계정으로 맞춥니다:
   - `env.DOCKER_IMAGE: <your-dockerhub-username>/hello-app`
5. `main` 브랜치로 커밋/푸시합니다. GitHub Actions에서 `build-and-deploy` 워크플로가 실행됩니다.
6. 배포 완료 후 `https://<AZURE_WEBAPP_NAME>.azurewebsites.net`에서 서비스가 제공되는지 확인합니다.
7. 프로젝트의 index.html 을 수정하면 `https://<AZURE_WEBAPP_NAME>.azurewebsites.net` 에 반영되는지 확인합니다.

아래는 실제 배포 단계 일부입니다.

```yaml
# .github/workflows/cicd.yml (발췌)
- name: Deploy to Azure Web App (container)
  uses: azure/webapps-deploy@v3
  with:
    app-name: ${{ secrets.AZURE_WEBAPP_NAME }}
    publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE }}
    images: index.docker.io/${{ env.DOCKER_IMAGE }}:${{ steps.vars.outputs.TAG }}
```

## 구성

- **베이스 이미지**: `nginxdemos/hello`
- **커스터마이즈**: `index.html`을 복사해 기본 페이지 대체
- **Dockerfile**: 빌드 시 정적 페이지를 이미지에 포함

## 로컬 테스트 (선택)

1. 로컬 빌드

```bash
docker build -t your-registry/azure-ci-cd-tutorial:local .
```

1. 실행

```bash
docker run --rm -p 8080:80 your-registry/azure-ci-cd-tutorial:local
```

브라우저에서 <http://localhost:8080> 으로 접속해 페이지를 확인하세요.
