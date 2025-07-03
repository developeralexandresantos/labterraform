# Dockerfile para ambiente DevContainer com Terraform, AWS CLI e LocalStack via venv
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Instala dependências básicas
RUN apt-get update && \
    apt-get install -y curl unzip git jq python3 python3-pip python3-venv

# Instala Terraform
ENV TERRAFORM_VERSION=1.8.4
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

# Cria ambiente virtual para ferramentas Python
ENV VENV_PATH=/opt/aws-tools-venv
RUN python3 -m venv $VENV_PATH

# Instala ferramentas Python dentro do venv
RUN $VENV_PATH/bin/pip install --upgrade pip && \
    $VENV_PATH/bin/pip install awscli awscli-local localstack

# Adiciona o venv ao PATH
ENV PATH="$VENV_PATH/bin:$PATH"

# Cria diretório de trabalho
WORKDIR /workspace
