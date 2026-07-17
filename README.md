# Hello Pipeline OpenShift

This project provides a simple CI/CD pipeline for OpenShift with a production-style flow: clone the app, build an immutable image in OpenShift, and deploy it directly to the cluster. GitOps is intentionally deferred to a later phase.

## Portfolio Focus

This repository demonstrates hands-on OpenShift delivery automation with Tekton. It is useful as a portfolio project because it shows a complete deployment path instead of isolated YAML examples: source checkout, Git SHA extraction, image build, immutable deployment by digest, rollout validation, and smoke testing.

## Repository Layout

- **pipeline/**: Tekton pipeline and task manifests.
- **run/**: A manual `PipelineRun` example for the current flow.
- **webhook/**: Kept for the future GitOps/webhook phase.
- **README.md**: Project overview and setup instructions.

## Current Flow

1. Clone the application repository.
2. Extract the short Git SHA from the source tree.
3. Build an image with OpenShift binary build and tag it in the internal registry.
4. Deploy the image by immutable digest to OpenShift.
5. Run a smoke test against the route.

## Technologies

- **OpenShift**
- **Tekton Pipelines**
- **OpenShift Builds / ImageStreams**
- **OpenShift Routes**

## What this demonstrates

- Pipeline design for a Java application delivery flow.
- Separation between reusable task manifests and manual `PipelineRun` examples.
- Immutable image promotion using image digest instead of mutable tags.
- Basic operational validation with rollout checks and smoke tests.
- Local cluster experimentation with OpenShift Local / CRC.

## OpenShift Local / CRC

- Use the `hello-pipeline` namespace.
- The app is deployed directly in OpenShift for the current phase.
- The deployment task waits for rollout and then runs a smoke test against the exposed route.
- GitOps and GitHub webhook integration will be reintroduced later, after this base flow is stable.

## Prerequisites

- An OpenShift cluster or OpenShift Local / CRC.
- Tekton Pipelines installed.
- Access to the GitHub repository that contains the application source.

## Install

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
oc apply -f run/05-run.yaml
```

## Manual Run

```bash
oc create -f run/05-run.yaml -n hello-pipeline
```

Then watch the run with:

```bash
oc get pipelinerun,taskrun,pod,build -n hello-pipeline
```

## Notes

- The application is deployed by immutable digest, not by a mutable tag.
- The deploy task validates rollout and performs a smoke test against the route.
- The GitOps task and webhook manifests remain in the repository for the next phase, but they are not part of the active pipeline.

## License

GPL-3.0
