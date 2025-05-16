# Hello Pipeline OpenShift

Este projeto fornece uma configuração de pipeline para implantação contínua de aplicações no OpenShift, utilizando Openshift Pipelines (Tekton) e integração via webhooks do GitHub.

## 📂 Estrutura do Repositório

- **pipeline/**: Contém os manifests YAML para a configuração da pipeline Tekton.
- **run/**: Scripts ou arquivos necessários para a execução da pipeline.
- **webhook/**: Configurações relacionadas à integração com webhooks do GitHub.
- **.gitignore**: Lista de arquivos e diretórios a serem ignorados pelo Git.
- **LICENSE**: Licença GPL-3.0 que rege este projeto.
- **README.md**: Este arquivo, fornecendo informações sobre o projeto.

## 🛠️ Tecnologias Utilizadas

- **OpenShift**: Plataforma de orquestração de containers baseada em Kubernetes.
- **Openshift Pipelines**: Framework nativo de Kubernetes para criação de pipelines CI/CD.
- **GitHub Webhooks**: Mecanismo para integrar eventos do GitHub com serviços externos.

## ⚙️ Pré-requisitos

- **Cluster OpenShift**: Acesso a um cluster OpenShift configurado.
- **Openshift Pipelines**: Operador Openshift Pipelines instalado no cluster OpenShift.
- **Repositório GitHub**: Repositório da sua aplicação com permissões para configurar webhooks.

## 📋 Tasks Utilizadas na Pipeline

#### ✅ Tasks Oficiais (do Tekton Hub)

| Task        | Fonte                                                                   | Função                                                       |
| ----------- | ----------------------------------------------------------------------- | ------------------------------------------------------------ |
| `git-clone` | [tektoncd/task/git-clone](https://hub.tekton.dev/tekton/task/git-clone) | Clona o repositório da aplicação no workspace da pipeline.   |
| `kaniko`    | [tektoncd/task/kaniko](https://hub.tekton.dev/tekton/task/kaniko)       | Constrói a imagem da aplicação e realiza push no Docker Hub. |

#### 🛠️ Tasks Customizadas (definidas neste repositório)

| Task                     | Caminho no Repositório                                                                   | Função                                                           |
| ------------------------ | ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `update-kustomize-image` | [`pipeline/update-kustomize-image-task.yaml`](pipeline/update-kustomize-image-task.yaml) | Atualiza a imagem no `kustomization.yaml` do repositório GitOps. |
| `git-commit-push`        | [`pipeline/git-commit-push-task.yaml`](pipeline/git-commit-push-task.yaml)               | Comita e realiza push das alterações no repositório GitOps.      |

## 🚀 Configuração e Execução

1. **Configurar Webhook no GitHub**:

   - No repositório da sua aplicação no GitHub, vá em _Settings_ > _Webhooks_.
   - Clique em _Add webhook_ e configure a URL do serviço receptor no OpenShift.
   - Selecione os eventos que irão disparar a pipeline (por exemplo, _push_).

2. **Aplicar Manifests da Pipeline**:

   ```bash
   git clone https://github.com/marcelobruckner/hello-pipeline-openshift.git
   cd hello-pipeline-openshift/pipeline
   oc apply -f .
   ```

3. **Executar a Pipeline**:

   - A pipeline será disparada automaticamente pelos eventos configurados no webhook.
   - Para execução manual, utilize o Tekton CLI (`tkn`) ou a interface web do OpenShift.

## 🔍 Monitoramento

- Utilize o Tekton Dashboard para visualizar o progresso e logs das execuções da pipeline.
- Verifique os logs dos pods no OpenShift para depuração em caso de falhas.

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests.

## 📄 Licença

Este projeto está licenciado sob a Licença GPL-3.0. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.
