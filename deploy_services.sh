#!/bin/bash

# 에러 발생 시 스크립트 중단
set -e

# 환경 변수 설정 (기본값: prod)
ENV=${1:-prod}

# 로그 함수
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 서비스 배포
deploy_services() {
    local compose_file="services/docker-compose.${ENV}.yml"
    
    if [ ! -f "$compose_file" ]; then
        log "Error: Compose file $compose_file not found"
        exit 1
    fi
    
    log "Deploying services for $ENV environment..."
    docker stack deploy -c "$compose_file" "doez-${ENV}"
    log "Services deployed successfully"
}

# 서비스 상태 확인
check_services() {
    log "Checking service status..."
    docker service ls
}

# 메인 실행
main() {
    log "Starting deployment process for $ENV environment..."
    
    # 서비스 배포
    deploy_services
    
    # 상태 확인
    check_services
    
    log "Deployment completed successfully"
}

# 스크립트 실행
main 