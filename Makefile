.PHONY: up down tf-init tf-plan tf-apply tf-destroy check-localstack

# Variáveis com fallback para execução fora do devcontainer
AWS_ACCESS_KEY_ID ?= test
AWS_SECRET_ACCESS_KEY ?= test
AWS_REGION ?= sa-east-1
AWS_S3_FORCE_PATH_STYLE ?= true
LOCALSTACK_AUTH_TOKEN ?= ls-cAyI3905-wobe-VuFa-ZERA-sAwoKevE573b

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION
export AWS_S3_FORCE_PATH_STYLE
export LOCALSTACK_AUTH_TOKEN

up:
	docker compose up -d

down:
	docker compose down

check-localstack:
	@echo "🔍 Verificando status do LocalStack..."
	@if ! curl -s http://localhost:4566/_localstack/health | jq -e '.services.s3 == "running"' > /dev/null; then \
		echo "⚠️ S3 ainda não está 'running', forçando ativação..."; \
		awslocal s3 ls > /dev/null 2>&1 || true; \
		sleep 2; \
	fi

	@# Verifica novamente se o S3 ativou
	@if curl -s http://localhost:4566/_localstack/health | jq -e '.services.s3 == "running"' > /dev/null; then \
		echo "✅ LocalStack está saudável e S3 está running!"; \
	else \
		echo "❌ S3 não está ativo. Verifique os logs do LocalStack."; \
		exit 1; \
	fi

tf-init: check-localstack
	terraform init

tf-plan: check-localstack
	terraform plan -out=tfplan.out

tf-apply: check-localstack
	terraform apply tfplan.out

tf-destroy: check-localstack
	terraform destroy -auto-approve
