# Hello Pipeline OpenShift

Este repositório mantém uma pipeline simples de CI/CD para OpenShift usando Tekton. O fluxo atual clona a aplicação, extrai o SHA do commit, constrói uma imagem dentro do OpenShift, faz deploy direto no cluster por digest imutável e valida o resultado com rollout e smoke test.

GitOps e integração por webhook foram preservados no repositório, mas estão intencionalmente fora do caminho ativo desta fase.

## Objetivo

Demonstrar uma entrega automatizada ponta a ponta no OpenShift, com foco em um fluxo pequeno, validável e adequado para OpenShift Local / CRC:

1. clonar o repositório da aplicação;
2. identificar o commit usado no build;
3. construir a imagem com `BuildConfig` e `ImageStream`;
4. publicar a imagem por digest imutável;
5. atualizar `Deployment`, `Service` e `Route`;
6. validar o rollout e o endpoint da aplicação.

## Por que este projeto existe

Este é um projeto de portfólio e laboratório prático de entrega em OpenShift. Ele mostra mais do que manifests isolados: o repositório contém o fluxo de checkout, extração de SHA, build, deploy, validação operacional e execução manual da pipeline.

## Tecnologias

- OpenShift
- OpenShift Local / CRC
- Tekton Pipelines
- OpenShift Builds
- ImageStreams
- Routes

## Estrutura do Repositório

- `pipeline/`: manifests da pipeline, tasks, RBAC, PVC, `BuildConfig` e `ImageStream`.
- `run/`: exemplo de `PipelineRun` manual para o fluxo atual.
- `webhook/`: manifests mantidos para a fase futura de webhook/GitOps.
- `CONTEXTO.md`: resumo operacional do estado atual do projeto.
- `install-local.sh`: script de instalação dos recursos ativos no namespace.

## Fluxo Ativo

O caminho ativo da pipeline é:

```text
fetch-source -> get-git-sha -> build-image -> deploy-to-dev
```

Etapas:

1. `fetch-source` clona o repositório da aplicação.
2. `get-git-sha` extrai o SHA curto do commit.
3. `build-image` dispara um build binário do OpenShift e publica a imagem no `ImageStream`.
4. `deploy-to-dev` aplica ou atualiza os recursos da aplicação no OpenShift.
5. A task de deploy aguarda o rollout e executa um smoke test via `curl`.

## Pré-requisitos

- Cluster OpenShift ou OpenShift Local / CRC.
- OpenShift Pipelines instalado.
- CLI `oc` autenticada no cluster.
- Acesso ao repositório da aplicação configurado na pipeline.

Por padrão, a pipeline usa:

```text
https://github.com/marcelobruckner/hello-app
```

## Instalação Local

O caminho recomendado para instalar os recursos ativos é usar o script:

```bash
./install-local.sh
```

Ele cria ou seleciona o namespace `hello-pipeline` e aplica os manifests necessários para a fase atual.

Observação: o namespace padrão do fluxo atual é `hello-pipeline`. Os manifests ainda usam esse namespace em campos `metadata.namespace` e parâmetros internos, então a execução em outro namespace exige revisar os YAMLs antes de aplicar.

## Instalação Manual

Se preferir aplicar os manifests manualmente:

```bash
oc new-project hello-pipeline
oc apply -f pipeline/06-serviceaccount.yaml
oc apply -f pipeline/10-rbac-deploy.yaml
oc apply -f pipeline/04-pvc.yaml
oc apply -f pipeline/07-get-git-sha.yaml
oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml
oc apply -f pipeline/11-image-stream.yaml
oc apply -f pipeline/12-buildconfig.yaml
oc apply -f pipeline/13-build-openshift-image.yaml
oc apply -f pipeline/08-deploy-openshift.yaml
oc apply -f pipeline/03-pipeline.yaml
```

## Executar a Pipeline

Crie um `PipelineRun` manual:

```bash
oc create -f run/05-run.yaml -n hello-pipeline
```

Acompanhe a execução:

```bash
oc get pipelinerun,taskrun,pod,build -n hello-pipeline
```

Para ver detalhes de uma execução específica:

```bash
oc describe pipelinerun <nome-do-pipelinerun> -n hello-pipeline
oc get pod -n hello-pipeline
```

## Validação

Ao final da pipeline, a aplicação deve estar publicada por `Deployment`, `Service` e `Route`.

Comandos úteis:

```bash
oc get deployment,svc,route -n hello-pipeline
oc rollout status deployment/hello -n hello-pipeline
oc get route hello -n hello-pipeline
```

A task `deploy-openshift` também faz um smoke test interno contra:

```text
http://hello:8080/
```

## Notas Operacionais

- A imagem é implantada por digest imutável, não por tag mutável.
- O build usa recursos nativos do OpenShift, não Docker Hub.
- O fluxo atual não depende de workspace GitOps.
- Os manifests de GitOps e webhook permanecem no repositório para evolução futura.
- Em OpenShift Local / CRC, se pods de workspace não agendarem, verifique a configuração `coschedule` do OpenShift Pipelines.

## Fase Futura

A próxima fase pode reintroduzir GitOps e webhook em cima do fluxo atual já validado. Os arquivos relacionados continuam no repositório, mas não devem ser considerados parte da pipeline ativa até essa evolução.

## Licença

GPL-3.0
