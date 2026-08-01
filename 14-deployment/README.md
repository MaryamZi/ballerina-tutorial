# 14. Deployment — build a Docker image and Kubernetes manifests

Sample 11's isolated products service, packaged for deployment. `bal build` produces a Docker image and a set of Kubernetes YAMLs (Deployment, Service, HorizontalPodAutoscaler) — no hand-written manifests.

## Steps

### 1. Copy sample 11 as the app

Start from `11-service-isolated/` — same service code, same `api.hurl`.

### 2. Enable Cloud in `Ballerina.toml`

```toml
[build-options]
observabilityIncluded = true
cloud = "k8s"
```

`cloud = "k8s"` tells Ballerina to emit both a Docker image and Kubernetes manifests. Swap `"k8s"` for `"docker"` to just build the image. See [Kubernetes deployment](https://ballerina.io/learn/by-example/kubernetes-hello-world/) and [Docker deployment](https://ballerina.io/learn/by-example/docker-hello-world/) for the underlying examples.

### 3. Add `Cloud.toml`

```toml
[container.image]
repository = "tutorial"
name = "products-deployment"
tag = "0.1.0"
```

The image name, repo, and tag drive the generated YAMLs. Every other setting (replicas, resource limits, service type, HPA) uses sensible defaults.

### 4. Build

```
bal build
```

Emits:

- `target/docker/products_deployment/` — the built image (`tutorial/products-deployment:0.1.0`).
- `target/kubernetes/products_deployment/products_deployment.yaml` — Service + Deployment + HorizontalPodAutoscaler.

### 5. Deploy

Needs a running Kubernetes cluster and a `kubectl` context pointing at it — Docker Desktop's built-in k8s, Rancher Desktop, `minikube start`, `kind create cluster`, or an OpenShift cluster via `oc login`.

```
kubectl apply -f target/kubernetes/products_deployment
```

The generated Service is `ClusterIP`. To expose it locally, create a `NodePort` from the Deployment — this is what `bal build` prints at the end of its output:

```
kubectl expose deployment products-deploy-deployment --type=NodePort --name=products-deploy-svc-local
```

Look up the assigned node port:

```
kubectl get svc products-deploy-svc-local
```

The `PORT(S)` column shows `9093:<nodePort>/TCP`. Use that port for the calls in step 6.

Alternatively, `kubectl port-forward svc/products-deploy 9093:9093` keeps port 9093 locally with no lookup.

### 6. Exercise the API

Same endpoints and `api.hurl` as sample 11:

```
hurl --test api.hurl
```

## Tear down

Delete the resources created from the generated manifests:

```
kubectl delete -f target/kubernetes/products_deployment
```

If you exposed the deployment via `NodePort`, remove that too:

```
kubectl delete svc products-deploy-svc-local
```

## Customizing

`Cloud.toml` sections beyond the image, all optional:

- `[cloud.deployment]` — CPU and memory requests/limits (e.g. `min_memory = "100Mi"`, `max_cpu = "500m"`).
- `[cloud.deployment.autoscaling]` — `min_replicas`, `max_replicas`, target CPU percentage (drives the generated `HorizontalPodAutoscaler`).
- `[cloud.deployment.probes.liveness]` / `[cloud.deployment.probes.readiness]` — port and path.
- `[[cloud.config.files]]` — mount `Config.toml` as a Kubernetes `ConfigMap` at `/home/ballerina/conf/`. `Config.toml` is never baked into the image (it may hold secrets); this is how the container reads it at runtime.

See the [code-to-cloud reference](https://ballerina.io/learn/code-to-cloud-deployment/) for the full schema.

## Docker only

Change `cloud = "docker"` in `Ballerina.toml`. `bal build` skips the Kubernetes manifests and produces just the image:

```
docker run --rm -p 9093:9093 tutorial/products-deployment:0.1.0
```

See [Docker deployment](https://ballerina.io/learn/by-example/docker-hello-world/) for more.

## OpenShift

Set `cloud = "openshift"` in `Ballerina.toml`. `bal build` writes the same manifests (Service, Deployment, HorizontalPodAutoscaler) to `target/openshift/products_deployment/` and prints an `oc apply` command instead of `kubectl apply`. The `cloud = "k8s"` output works on OpenShift too — the OpenShift target just tailors the output directory and the applied-command hint.
