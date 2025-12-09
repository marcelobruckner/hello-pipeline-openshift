#!/bin/bash

# Script para alterar o namespace em todos os arquivos YAML do projeto

if [ -z "$1" ]; then
  echo "❌ Erro: Você precisa informar o novo namespace"
  echo "Uso: ./change-namespace.sh SEU_NAMESPACE"
  exit 1
fi

NEW_NAMESPACE=$1
OLD_NAMESPACE="luis-bruckner-dev"

echo "🔄 Alterando namespace de '$OLD_NAMESPACE' para '$NEW_NAMESPACE'..."
echo ""

# Lista de arquivos a serem alterados
FILES=(
  "pipeline/01-buildah-customized.yaml"
  "pipeline/02-update-commit-mainfest.yaml"
  "pipeline/03-pipeline.yaml"
  "pipeline/04-pvc.yaml"
  "pipeline/05-pvc-gitops.yaml"
  "pipeline/06-serviceaccount.yaml"
  "pipeline/07-get-git-sha.yaml"
  "pipeline/08-deploy-openshift.yaml"
  "run/05-run.yaml"
  "webhook/eventlistener.yaml"
  "webhook/route.yaml"
  "webhook/triggerbinding.yaml"
  "webhook/triggertemplate.yaml"
)

# Alterar namespace em cada arquivo
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    sed -i "s/namespace: $OLD_NAMESPACE/namespace: $NEW_NAMESPACE/g" "$file"
    echo "✅ $file"
  else
    echo "⚠️  $file (não encontrado)"
  fi
done

echo ""
echo "✨ Concluído! Namespace alterado para '$NEW_NAMESPACE' em todos os arquivos."
echo ""
echo "📋 Próximos passos:"
echo "1. Criar secret do Docker Hub:"
echo "   oc create secret docker-registry dockerhub-secret-2 \\"
echo "     --docker-server=docker.io \\"
echo "     --docker-username=SEU_USUARIO \\"
echo "     --docker-password=SEU_TOKEN \\"
echo "     -n $NEW_NAMESPACE"
echo ""
echo "2. Configurar autenticação GitHub para push no repo GitOps"
echo "   (adicionar token no URL ou configurar SSH)"
echo ""
echo "3. Instalar tasks do Tekton Hub:"
echo "   oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml"
echo "   oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kaniko/0.6/kaniko.yaml"
echo ""
echo "4. Aplicar os manifests:"
echo "   oc apply -f pipeline/"
echo "   oc apply -f webhook/"
