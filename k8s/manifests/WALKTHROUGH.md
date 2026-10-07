# Workshop Walkthrough

Hands-on tour of Pods, ReplicaSets, Deployments, Services, ConfigMaps and Secrets using [podinfo](https://github.com/stefanprodan/podinfo).

All commands are run from `k8s/manifests`. Every step has a different UI color so you can see which one you're looking at.

```bash
cd k8s/manifests
```

> Note: `port-forward` is tied to a specific pod (or to the one pod chosen when the command starts). When that pod is replaced, the forward breaks. Stop it with Ctrl+C and start it again.

## 0. Namespace

```bash
kubectl apply -f namespace.yaml
kubectl get ns podinfo
```

## 1. Pod (blue)

```bash
kubectl apply -f pod.yaml
kubectl -n podinfo get pods -o wide        # wait for Running, READY 1/1
kubectl -n podinfo port-forward pod/podinfo-pod 9898:9898
```

Open http://localhost:9898 -> blue, "Hello from a bare Pod".

**Try:**
- `kubectl -n podinfo delete pod podinfo-pod` -> it's gone for good, nobody recreates it.

## 2. ReplicaSet (green)

```bash
kubectl apply -f replicaset.yaml
kubectl -n podinfo get rs,pods
```

Port-forward to one of the pods (use a real pod name from the output):

```bash
kubectl -n podinfo port-forward pod/<podinfo-rs-xxxxx> 9898:9898
```

Open http://localhost:9898 -> green, "Hello from a ReplicaSet".

**Try:**
- Delete one pod -> the ReplicaSet creates a replacement immediately.
- `kubectl -n podinfo scale rs/podinfo-rs --replicas=5`
- Change the image tag in `replicaset.yaml` and re-apply -> existing pods are **not** updated. That's what Deployments are for.

## 3. Deployment (purple)

Clean up the previous steps first:

```bash
kubectl delete -f replicaset.yaml -f pod.yaml
kubectl apply -f deployment.yaml
kubectl -n podinfo get deploy,rs,pods
kubectl -n podinfo port-forward deploy/podinfo 9898:9898
```

Open http://localhost:9898 -> purple, "Hello from a Deployment".

**Try:**
- Change the image tag to `6.7.1` in `deployment.yaml`, re-apply, and watch with `kubectl -n podinfo get pods -w`.
- `kubectl -n podinfo rollout status deploy/podinfo`
- `kubectl -n podinfo rollout undo deploy/podinfo`
- Change `PODINFO_UI_COLOR` / `PODINFO_UI_MESSAGE` and re-apply -> new pods roll out.

## 4. Service

```bash
kubectl apply -f service.yaml
kubectl -n podinfo get svc,endpoints
kubectl -n podinfo port-forward svc/podinfo 8080:80
```

Open http://localhost:8080.

**Try:**
- Reload the page, or run `curl -s localhost:8080` repeatedly, and watch the hostname. The Service spreads requests across pods.
- `kubectl -n podinfo scale deploy/podinfo --replicas=5` and watch the endpoints change.
- Change the selector in `service.yaml` to a label that matches nothing -> the endpoints become empty.
- DNS inside the cluster:
  ```bash
  kubectl -n podinfo run tmp --rm -it --image=busybox --restart=Never -- wget -qO- http://podinfo/
  ```

## 5. ConfigMap (orange)

Create the ConfigMap:

```bash
kubectl apply -f configmap.yaml
```

The Deployment doesn't use it yet. In `deployment.yaml`, delete the `env:` block and uncomment `configMapRef` under `envFrom:`:

```yaml
          envFrom:
            - configMapRef:
                name: podinfo-config
```

Leave `secretRef` commented out for now, then:

```bash
kubectl apply -f deployment.yaml
kubectl -n podinfo port-forward svc/podinfo 8080:80
```

Open http://localhost:8080 -> orange, "Hello from a ConfigMap".

**Live edit alternative:** `kubectl -n podinfo edit deploy/podinfo`, replace the `env:` entries with the `envFrom:` block above. Note that `deployment.yaml` then no longer matches the cluster, and a later `kubectl apply -f deployment.yaml` puts the old values back.

**Try:**
- In `configmap.yaml` set `PODINFO_UI_COLOR: "#ec4899"` and the message to `"Hello from a ConfigMap (v2)"`, then `kubectl apply -f configmap.yaml`. Reload: still orange, because env vars are only read when a container starts.
- `kubectl -n podinfo rollout restart deploy/podinfo`, then `kubectl -n podinfo rollout status deploy/podinfo`.
- Restart the port-forward and reload -> pink.

## 6. Secret

Create the Secret **before** referencing it, or the pods fail with `CreateContainerConfigError`:

```bash
kubectl apply -f secret.yaml
```

In `deployment.yaml`, uncomment `secretRef` so `envFrom` has both:

```yaml
          envFrom:
            - configMapRef:
                name: podinfo-config
            - secretRef:
                name: podinfo-secret
```

```bash
kubectl apply -f deployment.yaml
kubectl -n podinfo port-forward svc/podinfo 8080:80
curl -s localhost:8080/env | grep DB_PASSWORD
```

You can also open http://localhost:8080/env in the browser. `DB_PASSWORD` is visible in plain text.

**Try:**
- `kubectl -n podinfo get secret podinfo-secret -o jsonpath='{.data.DB_PASSWORD}' | base64 -d`

**Takeaway:** base64 is encoding, not encryption. Anyone who can read the Secret, reach the app, or `exec` into the pod can see the value. Restrict access with RBAC, and never commit real secrets to git.

## Clean up

```bash
kubectl delete ns podinfo
```
