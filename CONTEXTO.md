# Contexto do Projeto

Data: 2026-06-16

## Objetivo Atual

Manter uma pipeline simples e robusta para CI/CD no OpenShift, com foco em:

1. clonar a aplicacao
2. construir a imagem no OpenShift
3. deployar por digest imutavel
4. validar o rollout com smoke test

## O que esta ativo agora

- `fetch-source` clona o repositório da aplicação.
- `get-git-sha` extrai o SHA curto do commit.
- `build-image` dispara um build binario do OpenShift e publica a imagem no `ImageStream`.
- `deploy-to-dev` aplica `Deployment`, `Service` e `Route` no OpenShift, depois valida o acesso com `curl`.
- O `PipelineRun` manual usa apenas o workspace de source; nao ha workspace de GitOps no fluxo atual.

## Melhorias aplicadas

- Pipeline, Tasks e `PipelineRun` padronizados em `tekton.dev/v1`.
- Deploy por digest imutavel, em vez de depender de tag mutavel.
- Smoke test apos o rollout para validar o endpoint real da aplicacao.
- RBAC reduzido ao conjunto minimo necessario para build e deploy.
- ServiceAccount enxuto, sem segredos GitHub montados no caminho ativo.

## Fase futura

A integracao com GitOps vai voltar em outra fase, em cima do fluxo atual ja estabilizado.

## Arquivos principais

- `pipeline/03-pipeline.yaml`
- `pipeline/07-get-git-sha.yaml`
- `pipeline/13-build-openshift-image.yaml`
- `pipeline/08-deploy-openshift.yaml`
- `pipeline/06-serviceaccount.yaml`
- `pipeline/10-rbac-deploy.yaml`
- `run/05-run.yaml`

## Estado operacional

O fluxo manual atual ja foi validado no CRC e serve como base para a proxima iteracao.
