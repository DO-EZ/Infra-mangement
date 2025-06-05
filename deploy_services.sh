#!/bin/bash

# 에러 발생 시 스크립트 중단
set -e

# 로그 함수
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Docker Swarm 초기화 확인
init_swarm() {
    log "Checking Docker Swarm status..."
    if ! docker info | grep -q "Swarm: active"; then
        log "Initializing Docker Swarm..."
        docker swarm init
        log "Docker Swarm initialized successfully"
    else
        log "Docker Swarm is already active"
    fi
}

# Docker 네트워크 생성
create_network() {
    log "Checking traefik-network..."
    if ! docker network ls | grep -q traefik-network; then
        log "Creating traefik-network..."
        docker network create --driver overlay --attachable traefik-network
        log "Network created successfully"
    else
        log "Network already exists"
    fi
}

# 서비스 배포 함수
deploy_service() {
    local compose_file=$1
    local service_name=$2
    
    log "Deploying $service_name..."
    docker stack deploy -c "$compose_file" "$service_name"
    log "$service_name deployed successfully"
}

# 모든 서비스 배포
deploy_all_services() {
    log "Deploying all services..."
    
    # Backend 배포
    deploy_service "backend/docker-compose.prod.yml" "backend"
    
    # Frontend 배포
    deploy_service "frontend/docker-compose.prod.yml" "frontend"
    
    # MLflow 배포
    deploy_service "mlflow/docker-compose.yml" "mlflow"
    
    # Ingress 배포 (root의 docker-compose.yml 사용)
    deploy_service "docker-compose.yml" "ingress"
    
    log "All services deployed successfully"
}

# 서비스 상태 확인
check_services() {
    log "Checking service status..."
    docker service ls
}

# 메인 실행
main() {
    log "Starting deployment process..."
    
    # 네트워크 생성
    create_network
    
    # 서비스 배포
    deploy_all_services
    
    # 상태 확인
    check_services
    
    log "Deployment completed successfully"
}

# 스크립트 실행
main 