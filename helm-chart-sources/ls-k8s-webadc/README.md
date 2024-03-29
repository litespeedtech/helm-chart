LiteSpeed Ingress Controller in Kubernetes
==========================================

The LiteSpeed Ingress Controller is a specially designed Kubernetes application and uses the LiteSpeed WebADC controller to operate as an Ingress Controller and Load Balancer to properly manage your traffic on your Kubernetes cluster.

It is based on the [nginx](https://github.com/kubernetes-retired/contrib/tree/master/ingress/controllers/nginx) and [nghttpx](https://github.com/zlabjp/nghttpx-ingress-lb) ingress controllers.


## Introduction

This chart bootstraps a LiteSpeed Ingress deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Prerequisites

- Kubernetes 1.19+
- Helm 3.1.0

## Selecting a Namespace

The default namespace is not generally where new pods and services are loaded into.  The `kube-system` namespace is the default for most system pods and a load balancer can be considered one of those.  However, your environment may have restrictions on using `kube-system` so you may choose to use a non-system namespace like `ls-k8s-webadc` to have the namespace match the other names in the system.

Namespace is required on most Kubernetes commands so this document will use the name NAMESPACE to indicate the namespace you have selected.

## Adding a License

The LiteSpeed Kubernetes Ingress controller uses the LiteSpeed WebADC engine which is a licensed program product.  To use it you must obtain either a `trial.key` file for a trial or a `license.key` and `serial.no` files for a full license.  The Docker image requires that you define a generic secret to successfully run the software.

For a trial, place the trial.key file in the default directory and run:

```bash
$ kubectl create secret generic -n NAMESPACE ls-k8s-webadc --from-file=trial=./trial.key
```

For a full license, create the serial.no file as per [standalone license activation](https://docs.litespeedtech.com/licenses/how-to/#activate-a-license) and create the serial secret:

```bash
$ echo "SERIAL_NO" > /usr/local/lslb/conf/serial.no
$ kubectl create secret generic -n NAMESPACE ls-k8s-webadc --from-file=serial=./serial.no
```

The LiteSpeed Ingress Controller will read and verify the serial.no, create a license.key in the directory internally and a license secret for later consumption.  This only needs to be done once per serial number.

## Making HTTPS Work

(Optional) To make HTTPS work for the default backend you must apply a private key file and a certificate file as another secret definition.  If the private key file is named `key.pem` and the certificate file named `cert.pem` you would specify:

```bash
$ kubectl create secret tls -n NAMESPACE ls-k8s-webadc-tls --key key.pem --cert cert.pem
```

If you have a separate ca_bundle as well (often called an intermediate), please append the contents of that after the certificate file's contents.

## Installing the Chart

To install the chart with the latest release from the ls-k8s-webadc directory:

```bash
$ helm repo add ls-k8s-webadc https://litespeedtech.github.io/helm-chart/
$ helm install ls-k8s-webadc ls-k8s-webadc/ls-k8s-webadc -n NAMESPACE
```

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
$ helm delete ls-k8s-webadc -n NAMESPACE
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |


### Common parameters

| Name                | Description                                        | Value |
| ------------------- | -------------------------------------------------- | ----- |
| `nameOverride`      | String to partially override common.names.fullname | `""`  |
| `fullnameOverride`  | String to fully override common.names.fullname     | `""`  |
| `commonLabels`      | Add labels to all the deployed resources           | `{}`  |
| `commonAnnotations` | Add annotations to all the deployed resources      | `{}`  |
| `extraDeploy`       | Array of extra objects to deploy with the release  | `[]`  |


### LiteSpeed Ingress Controller parameters

| Name                          | Description                                                                                                                                        | Value                              |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `image.registry`              | LiteSpeed Ingress Controller image registry                                                                                                        | `docker.io`                        |
| `image.repository`            | LiteSpeed Ingress Controller image repository                                                                                                      | `litespeedtech/ls-k8`              |
| `image.tag`                   | LiteSpeed Ingress Controller image tag                                                                                                             | `latest`                           |
| `image.pullPolicy`            | LiteSpeed Ingress Controller image pull policy                                                                                                     | `Always`                           |
| `image.pullSecrets`           | Specify docker-registry secret names as an array                                                                                                   | `[]`                               |
| `defaultBackendService`       | Default 404 backend service.                                                                                                                       | `""`                               |
| `publishService.enabled`      | Set the endpoint records on the Ingress objects to reflect those on the service                                                                    | `false`                            |
| `publishService.pathOverride` | Allows overriding of the publish service to bind to                                                                                                | `""`                               |
| `scope.enabled`               | Limit the scope of the controller. Defaults to `.Release.Namespace`                                                                                | `false`                            |
| `command`                     | Override default container command (useful when using custom images)                                                                               | `[]`                               |
| `args`                        | Override default container args (useful when using custom images)                                                                                  | `[]`                               |
| `extraArgs`                   | Additional command line arguments.  Without leading dashes, comma separated, in quotes and curly braces.  See below for the full list.             | `{}`                               |
| `extraEnvVars`                | Extra environment variables to be set on LiteSpeed Ingress container                                                                               | `[]`                               |
| `extraEnvVarsSecret`          | Name of a existing Secret containing extra environment variables                                                                                   | `""`                               |


### LiteSpeed Ingress deployment / daemonset parameters

| Name                                                | Description                                                                                             | Value          |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | -------------- |
| `kind`                                              | Install as Deployment or DaemonSet                                                                      | `Deployment`   |
| `daemonset.useHostPort`                             | If `kind` is `DaemonSet`, this will enable `hostPort` for `TCP/80` and `TCP/443`                        | `false`        |
| `daemonset.hostPorts`                               | HTTP and HTTPS ports                                                                                    | `{}`           |
| `nodeName`                                          | Allows you to hardcode the node name if you wish.                                                       | `""`           |
| `replicaCount`                                      | Desired number of Controller pods                                                                       | `1`            |
| `updateStrategy`                                    | Strategy to use to update Pods                                                                          | `{}`           |
| `revisionHistoryLimit`                              | The number of old history to retain to allow rollback                                                   | `10`           |
| `podSecurityContext.enabled`                        | Enable Controller pods' Security Context                                                                | `true`         |
| `podSecurityContext.fsGroup`                        | Group ID for the container filesystem                                                                   | `1001`         |
| `containerSecurityContext.enabled`                  | Enable Controller containers' Security Context                                                          | `true`         |
| `containerSecurityContext.allowPrivilegeEscalation` | Switch to allow priviledge escalation on the Controller container                                       | `true`         |
| `containerSecurityContext.runAsUser`                | User ID for the Controller container                                                                    | `1001`         |
| `containerSecurityContext.capabilities.drop`        | Linux Kernel capabilities that should be dropped                                                        | `[]`           |
| `containerSecurityContext.capabilities.add`         | Linux Kernel capabilities that should be added                                                          | `[]`           |
| `minReadySeconds`                                   | How many seconds a pod needs to be ready before killing the next, during update                         | `0`            |
| `resources.limits`                                  | The resources limits for the Controller container                                                       | `{}`           |
| `resources.requests`                                | The requested resources for the Controller container                                                    | `{}`           |
| `livenessProbe.enabled`                             | Enable livenessProbe                                                                                    | `true`         |
| `livenessProbe.httpGet.path`                        | Request path for livenessProbe                                                                          | `/healthz`     |
| `livenessProbe.httpGet.port`                        | Port for livenessProbe                                                                                  | `11972`        |
| `livenessProbe.httpGet.scheme`                      | Scheme for livenessProbe                                                                                | `HTTP`         |
| `livenessProbe.initialDelaySeconds`                 | Initial delay seconds for livenessProbe                                                                 | `10`           |
| `livenessProbe.periodSeconds`                       | Period seconds for livenessProbe                                                                        | `10`           |
| `livenessProbe.timeoutSeconds`                      | Timeout seconds for livenessProbe                                                                       | `1`            |
| `livenessProbe.failureThreshold`                    | Failure threshold for livenessProbe                                                                     | `3`            |
| `livenessProbe.successThreshold`                    | Success threshold for livenessProbe                                                                     | `1`            |
| `readinessProbe.enabled`                            | Enable readinessProbe                                                                                   | `true`         |
| `readinessProbe.httpGet.path`                       | Request path for readinessProbe                                                                         | `/healthz`     |
| `readinessProbe.httpGet.port`                       | Port for readinessProbe                                                                                 | `11972`        |
| `readinessProbe.httpGet.scheme`                     | Scheme for readinessProbe                                                                               | `HTTP`         |
| `readinessProbe.initialDelaySeconds`                | Initial delay seconds for readinessProbe                                                                | `10`           |
| `readinessProbe.periodSeconds`                      | Period seconds for readinessProbe                                                                       | `10`           |
| `readinessProbe.timeoutSeconds`                     | Timeout seconds for readinessProbe                                                                      | `1`            |
| `readinessProbe.failureThreshold`                   | Failure threshold for readinessProbe                                                                    | `3`            |
| `readinessProbe.successThreshold`                   | Success threshold for readinessProbe                                                                    | `1`            |
| `customLivenessProbe`                               | Override default liveness probe                                                                         | `{}`           |
| `customReadinessProbe`                              | Override default readiness probe                                                                        | `{}`           |
| `lifecycle`                                         | LifecycleHooks to set additional configuration at startup                                               | `{}`           |
| `podLabels`                                         | Extra labels for Controller pods                                                                        | `{}`           |
| `podAnnotations`                                    | Annotations for Controller pods                                                                         | `{}`           |
| `priorityClassName`                                 | Controller priorityClassName                                                                            | `""`           |
| `hostNetwork`                                       | If the LiteSpeed deployment / daemonset should run on the host's network namespace                      | `false`        |
| `dnsPolicy`                                         | By default, while using host network, name resolution uses the host's DNS                               | `ClusterFirst` |
| `terminationGracePeriodSeconds`                     | How many seconds to wait before terminating a pod                                                       | `60`           |
| `podAffinityPreset`                                 | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                     | `""`           |
| `podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                | `soft`         |
| `nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`               | `""`           |
| `nodeAffinityPreset.key`                            | Node label key to match. Ignored if `affinity` is set.                                                  | `""`           |
| `nodeAffinityPreset.values`                         | Node label values to match. Ignored if `affinity` is set.                                               | `[]`           |
| `affinity`                                          | Affinity for pod assignment. Evaluated as a template.                                                   | `{}`           |
| `nodeSelector`                                      | Node labels for pod assignment. Evaluated as a template.                                                | `{}`           |
| `tolerations`                                       | Tolerations for pod assignment. Evaluated as a template.                                                | `[]`           |
| `extraVolumes`                                      | Optionally specify extra list of additional volumes for Controller pods                                 | `[]`           |
| `extraVolumeMounts`                                 | Optionally specify extra list of additional volumeMounts for Controller container(s)                    | `[]`           |
| `initContainers`                                    | Add init containers to the controller pods                                                              | `[]`           |
| `sidecars`                                          | Add sidecars to the controller pods.                                                                    | `[]`           |
| `customTemplate`                                    | Override template                                                                                       | `{}`           |
| `topologySpreadConstraints`                         | Topology spread constraints rely on node labels to identify the topology domain(s) that each Node is in | `[]`           |
| `podSecurityPolicy.enabled`                         | If true, create & use Pod Security Policy resources                                                     | `false`        |


### Default backend parameters

| Name                                                | Description                                                                               | Value                  |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------- | ---------------------- |
| `defaultBackend.enabled`                            | Enable a default backend based on LiteSpeed WebADC                                        | `false`                |
| `defaultBackend.hostAliases`                        | Add deployment host aliases                                                               | `[]`                   |
| `defaultBackend.image.registry`                     | Default backend image registry                                                            | `docker.io`            |
| `defaultBackend.image.repository`                   | Default backend image repository                                                          | `litespeedtech/ols-backend` |
| `defaultBackend.image.tag`                          | Default backend image tag (immutable tags are recommended)                                | `latest`               |
| `defaultBackend.image.pullPolicy`                   | Image pull policy                                                                         | `Always`               |
| `defaultBackend.image.pullSecrets`                  | Specify docker-registry secret names as an array                                          | `[]`                   |
| `defaultBackend.extraArgs`                          | Additional command line arguments to pass to LiteSpeed container                          | `{}`                   |
| `defaultBackend.containerPort`                      | HTTP container port number                                                                | `80`                   |
| `defaultBackend.serverBlockConfig`                  | LiteSpeed backend default server block configuration                                      | `""`                   |
| `defaultBackend.replicaCount`                       | Desired number of default backend pods                                                    | `1`                    |
| `defaultBackend.podSecurityContext.enabled`         | Enable Default backend pods' Security Context                                             | `false`                |
| `defaultBackend.podSecurityContext.fsGroup`         | Group ID for the container filesystem                                                     | `1001`                 |
| `defaultBackend.containerSecurityContext.enabled`   | Enable Default backend containers' Security Context                                       | `false`                |
| `defaultBackend.containerSecurityContext.runAsUser` | User ID for the Default backend container                                                 | `1001`                 |
| `defaultBackend.resources.limits`                   | The resources limits for the Default backend container                                    | `{}`                   |
| `defaultBackend.resources.requests`                 | The requested resources for the Default backend container                                 | `{}`                   |
| `defaultBackend.livenessProbe.enabled`              | Enable livenessProbe                                                                      | `true`                 |
| `defaultBackend.livenessProbe.httpGet.path`         | Request path for livenessProbe                                                            | `/healthz`             |
| `defaultBackend.livenessProbe.httpGet.port`         | Port for livenessProbe                                                                    | `http`                 |
| `defaultBackend.livenessProbe.httpGet.scheme`       | Scheme for livenessProbe                                                                  | `HTTP`                 |
| `defaultBackend.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                                   | `30`                   |
| `defaultBackend.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                          | `10`                   |
| `defaultBackend.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                         | `5`                    |
| `defaultBackend.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                       | `3`                    |
| `defaultBackend.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                       | `1`                    |
| `defaultBackend.readinessProbe.enabled`             | Enable readinessProbe                                                                     | `true`                 |
| `defaultBackend.readinessProbe.httpGet.path`        | Request path for readinessProbe                                                           | `/healthz`             |
| `defaultBackend.readinessProbe.httpGet.port`        | Port for readinessProbe                                                                   | `http`                 |
| `defaultBackend.readinessProbe.httpGet.scheme`      | Scheme for readinessProbe                                                                 | `HTTP`                 |
| `defaultBackend.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                                  | `0`                    |
| `defaultBackend.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                         | `5`                    |
| `defaultBackend.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                        | `5`                    |
| `defaultBackend.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                      | `6`                    |
| `defaultBackend.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                      | `1`                    |
| `defaultBackend.podLabels`                          | Extra labels for Controller pods                                                          | `{}`                   |
| `defaultBackend.podAnnotations`                     | Annotations for Controller pods                                                           | `{}`                   |
| `defaultBackend.priorityClassName`                  | priorityClassName                                                                         | `""`                   |
| `defaultBackend.podAffinityPreset`                  | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`       | `""`                   |
| `defaultBackend.podAntiAffinityPreset`              | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`  | `soft`                 |
| `defaultBackend.nodeAffinityPreset.type`            | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `""`                   |
| `defaultBackend.nodeAffinityPreset.key`             | Node label key to match. Ignored if `affinity` is set.                                    | `""`                   |
| `defaultBackend.nodeAffinityPreset.values`          | Node label values to match. Ignored if `affinity` is set.                                 | `[]`                   |
| `defaultBackend.affinity`                           | Affinity for pod assignment                                                               | `{}`                   |
| `defaultBackend.nodeSelector`                       | Node labels for pod assignment                                                            | `{}`                   |
| `defaultBackend.tolerations`                        | Tolerations for pod assignment                                                            | `[]`                   |
| `defaultBackend.service.type`                       | Kubernetes Service type for default backend                                               | `ClusterIP`            |
| `defaultBackend.service.port`                       | Default backend service port                                                              | `80`                   |
| `defaultBackend.pdb.create`                         | Enable/disable a Pod Disruption Budget creation for Default backend                       | `false`                |
| `defaultBackend.pdb.minAvailable`                   | Minimum number/percentage of Default backend pods that should remain scheduled            | `1`                    |
| `defaultBackend.pdb.maxUnavailable`                 | Maximum number/percentage of Default backend pods that may be made unavailable            | `""`                   |


### Traffic exposure parameters

| Name                               | Description                                                                                                                            | Value          |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| `service.type`                     | Kubernetes Service type for Controller                                                                                                 | `LoadBalancer` |
| `service.metrics.enabled`          | Whether Prometheus style metrics should be enabled at startup and exposed with appropriate annotations.                                | `false`        |
| `service.metrics.port`             | The port number exported to the internet by the service.  0 does not export a port.                                                    | `0`            |
| `service.metrics.targetPort`       | The port number exported only to the internal cluster applications.                                                                    | `9936`         |
| `service.ports.config`             | Service configuration port.  If set, the external port for the WebAdmin Console.  Usually set to 7090 if enabled. Can be set as a controller argument.| Not enabled    |
| `service.ports.http`               | Service HTTP port                                                                                                                      | `80`           |
| `service.ports.https`              | Service HTTPS port                                                                                                                     | `443`          |
| `service.nodePorts.http`           | Specify the nodePort value(s) for the LoadBalancer and NodePort service types for http.                                                | `""`           |
| `service.nodePorts.https`          | Specify the nodePort value(s) for the LoadBalancer and NodePort service types for https.                                               | `""`           |
| `service.nodePorts.tcp`            | Specify the nodePort value(s) for the LoadBalancer and NodePort service types for tcp.                                                 | `{}`           |
| `service.nodePorts.udp`            | Specify the nodePort value(s) for the LoadBalancer and NodePort service types for udp.                                                 | `{}`           |
| `service.annotations`              | Annotations for controller service                                                                                                     | `{}`           |
| `service.labels`                   | Labels for controller service                                                                                                          | `{}`           |
| `service.clusterIP`                | Controller Internal Cluster Service IP (optional)                                                                                      | `""`           |
| `service.externalIPs`              | Controller Service external IP addresses                                                                                               | `[]`           |
| `service.loadBalancerIP`           | Kubernetes LoadBalancerIP to request for Controller (optional, cloud specific)                                                         | `""`           |
| `service.loadBalancerSourceRanges` | List of IP CIDRs allowed access to load balancer (if supported)                                                                        | `[]`           |
| `service.externalTrafficPolicy`    | Set external traffic policy to: "Local" to preserve source IP on providers supporting it                                               | `""`           |
| `service.healthCheckNodePort`      | Set this to the managed health-check port the kube-proxy will expose. If blank, a random port in the `NodePort` range will be assigned | `0`            |


### RBAC parameters

| Name                         | Description                                                 | Value  |
| ---------------------------- | ----------------------------------------------------------- | ------ |
| `serviceAccount.create`      | Enable the creation of a ServiceAccount for Controller pods | `true` |
| `serviceAccount.name`        | Name of the created ServiceAccount                          | `""`   |
| `serviceAccount.annotations` | Annotations for service account.                            | `{}`   |
| `rbac.create`                | Specifies whether RBAC rules should be created              | `true` |


### Autoscaling parameteters
| Name                         | Description                                                 | Value   |
| ---------------------------- | ----------------------------------------------------------- | ------- |
| `autoscaling.enabled`        | Enables the Horizontal Pod Autoscaler                       | `false` |
| `autoscaling.minReplicas`    | The minimum number of replicas to start with.  Usually 1. | `1`     |
| `autoscaling.maxReplicas`    | The maximum number of replicas.  Kubernetes will only scale to the number of free nodes, so this value is only used if you have many free nodes. | `11` |
| `autoscaling.targetCPU`      | If you decide to scale, most users scale based on CPU utilization (in percent). | `50` |

### Other parameters

| Name                       | Description                                                               | Value   |
| -------------------------- | ------------------------------------------------------------------------- | ------- |
| `pdb.create`               | Enable/disable a Pod Disruption Budget creation for Controller            | `false` |
| `pdb.minAvailable`         | Minimum number/percentage of Controller pods that should remain scheduled | `1`     |
| `pdb.maxUnavailable`       | Maximum number/percentage of Controller pods that may be made unavailable | `""`    |
| `autoscaling.enabled`      | Enable autoscaling for Controller                                         | `false` |
| `autoscaling.minReplicas`  | Minimum number of Controller replicas                                     | `1`     |
| `autoscaling.maxReplicas`  | Maximum number of Controller replicas                                     | `11`    |
| `autoscaling.targetCPU`    | Target CPU utilization percentage                                         | `""`    |
| `autoscaling.targetMemory` | Target Memory utilization percentage                                      | `""`    |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install ls-k8s-webadc --set image.pullPolicy=Always helm/ls-k8s-webadc
```
The above command sets the `image.pullPolicy` to `Always`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install my-release -f values.yaml helm/ls-k8s-webadc
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and installation details

### [Rolling VS Immutable tags](https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/)

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Bitnami will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.

### Sidecars and Init Containers

If you have a need for additional containers to run within the same pod as the LiteSpeed Ingress Controller (e.g. an additional metrics or logging exporter), you can do so via the `sidecars` config parameter. Simply define your container according to the Kubernetes container spec.

```yaml
sidecars:
  - name: your-image-name
    image: your-image
    imagePullPolicy: Always
    ports:
      - name: portname
       containerPort: 1234
```

Similarly, you can add extra init containers using the `initContainers` parameter.

```yaml
initContainers:
  - name: your-image-name
    image: your-image
    imagePullPolicy: Always
    ports:
      - name: portname
        containerPort: 1234
```

### Deploying extra resources

There are cases where you may want to deploy extra objects, such a ConfigMap containing your app's configuration or some extra deployment with a micro service used by your app. For covering this case, the chart allows adding the full specification of other objects using the `extraDeploy` parameter.

### Setting Pod's affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Find more information about Pod's affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

As an alternative, you can use of the preset configurations for pod affinity, pod anti-affinity, and node affinity available at the [bitnami/common](https://github.com/bitnami/charts/tree/master/bitnami/common#affinities) chart. To do so, set the `podAffinityPreset`, `podAntiAffinityPreset`, or `nodeAffinityPreset` parameters.

And if necessary you can hard code the node the Deployment schedules a pod to with `nodeName`.


## LiteSpeed Kubernetes Ingress Controller Arguments

The LiteSpeed Kubernetes Ingress Controller arguments are specified in helm with the `extraArgs` list above or if you are creating or modifying your own .yaml files in `spec/template/spec/containers/args`.  In yaml files an initial leading dash is required for repeating parameters and the second double leading dash is required for all controller arguments.  When using helm `extraArgs` do not use leading dashes and comma separate parameters.

| Name | Description | Value |
| - | - | - |
| `--allow-internal-ip` | Allows the use address of type NodeInternalIP when fetching the external IP address.  This is the workaround for the cluster configuration where NodeExternalIP or NodeLegacyHostIP is not assigned or cannot be used. | `false` |
| `--config-service-port` | The port to expose for configuration if you wish to enable it.  Set to 0 to not expose the configuration; when non-zero should be set to 7090 in most cases. | `0` |
| `--config-service-target-port` | The port to be used internally for configuration within the pod. | `7090` |
| `--default-tls-secret` | Name of the Secret that contains TLS server certificate and secret key to enable TLS by default.  For those client connections which are not TLS encrypted, they are redirected to https URI permanently. | `NAMESPACE/ls-k8s-webadc.com` |
| `--deferred-shutdown-period` | How long the controller waits before actually starting shutting down when it receives shutdown signal. Specified as a Kubernetes duration. | `0` (immediate) | 
| `--endpoint-slices` | Get endpoints from EndpointSlice resource instead of Endpoints resource. | `false` |
| `--gateway-class` | GatewayClass which this controller is responsible for. | `lslbd` |
| `--healthz-port` | Port for healthz endpoint.  Can be any open port. | `11972` |
| `--ingress-class` | The IngressClass this controller is responsible for. | `lslbd` |
| `--ingress-class-controller` | The name of IngressClass controller for this controller.  This is the value specified in `IngressClass.spec.controller.` | `litespeedtech.com/lslbd` |
| `--lslb-cache-store-path` | Specifies the directory in the container to hold cached images.  This directory must be mounted and pre-created. | Default location
| `--lslb-config-map-prefix` | Specify namespace/name of the prefix to be used to store modified configuration files as ConfigMaps from the load balancer's configuration directories. | `lslb` using the pod's namespace |
| `--lslb-debug` | Set to true if you want LSLB tracing enabled on startup. | `false` |
| `--lslb-dir` | The directory in the Docker image where the LiteSpeed Web ADC is installed, the default of `/usr/local/lslb` is the default ADC directory. | `/usr/local/lslb` |
| `--lslb-enable-ocsp-stapling` | Enable OCSP stapling on ADC server. | `false` |
| `--lslb-http-port` | Port to listen to for HTTP (non-TLS) requests.  Specifying 0 disables HTTP port. | `80` |
| `--lslb-https-port` | Port to listen to for HTTPS (TLS) requests.  Specifying 0 disables HTTPS port. | `443` |
| `--lslb-license-secret` | The required secret to be used to identify the LS WebADC license file(s). | `NAMESPACE/ls-k8s-webadc` |
| `--lslb-max-conn` | Sent in the ZCUP command, lets you manually set it.  Set for all servers if set here.  | `1000` |
| `--lslb-priority` | Sent in the ZCUP command, only useful when the strategy is Fail-over, min value 0, default 100, max value 255. Set for all servers if set here. | `100` |
| `--lslb-replace-conf` | Lets you modify any parameters in the default lslbd_config.xml file.  Specify each parameter, in parens, (title=value).  For example (useIpInProxyHeader=1)(showVersionNumber=1). | none |
| `--lslb-wait-timeout` | Number of seconds to wait for lslb to start listening for ZeroConf events. | `10` |
| `--lslb-zeroconf-password` | The password to be used to access zero conf.  The default is `zero` and changing it is documented in [ZeroConf](https://docs.litespeedtech.com/products/lsadc/zeroconf/). | `zero` |
| `--lslb-zeroconf-port` | The port to be used to access zero conf in LiteSpeed Web ADC. | `7099` |
| `--lslb-zeroconf-user` | The user to be used to access zero conf.  Changing it is documented in [ZeroConf](https://docs.litespeedtech.com/products/lsadc/zeroconf/). | `zero` |
| `--profiling` | Enable profiling at the health port.  It exposes /debug/pprof/ endpoint. | `true` |
| `--publish-service` | Specify namespace/name of Service whose hostnames/IP addresses are set in Ingress resource instead of addresses of Ingress controller Pods.  Takes the form namespace/name. | `NAMESPACE/ls-k8s-webadc` |
| `--reload-burst` | Reload burst that can exceed reload-rate. | `1` |
| `--reload-rate` | Rate (QPS) of reloading LiteSpeed WebADC configuration to deal with frequent backend updates in a single batch. | `1.0` |
| `--run-before-lb` | A single line set of UNIX commands which are run before the load balancer is started.  Can be used to apply floating IPs or similar commands. | none |
| `--v` |  Sets info logging.  --v=4 is the most verbose. | `2` |
| `--update-status` | Update the load-balancer status of Ingress objects this controller satisfies.  Requires publish-service to be specified. | `true` |
| `--watch-namespace` | The namespace to watch for Ingress events. | All namespaces |

### Load Balancing Controller Arguments

There are additional LiteSpeed Kubernetes Ingress Controller arguments which are specific to modifying the operation of the load balancer specifically.  Most noteworthy are the `--lslb-affinity` and `--lslb-strategy` arguments but all of the following are important in modifying the load balancing of the controller.  Note that they are specifically designed to give you the features available in the Load Balancer configuration, Clusters tab.

| Name | Description | Value |
| - | - | - |
| `--lslb-affinity` | Set to false for no affinity (stateless) or true for affinity (stateful). | `true` |
| `--lslb-insert-cookie` | If specified, this is the name of a cookie to be inserted in the stream. | Do not insert cookie |
| `--lslb-config-map-prefix` |  Configuration files are stored as configMaps with the default prefix: lslb.  The format for this value is namespace/prefix.  Any watched files get saved with configMaps with the specified prefix and each directory from the $SERVER_ROOT. | `lslb` |
| `--lslb-ex-bitmap` | A bit map of all of the fields that can be used in identifying a session.  As a bitmap, add up all of the values you select. 1: IP address, 2: Basic authentication, 4: Query string, 8: Cookies, 16: SSL session, 32: JVM route, 64: URL path parameter. | `127` (all) |
| `--lslb-forward-by-header` | An additional header to be added to all proxy requests made to the backend server.  Typically ‘X-Forwarded-By’. | none |
| `--lslb-forward-ip-header` | An additional header to be added to all proxy requests made to the backend server.  This header will use either the visiting IP or the value set in the ‘X-Forwarded-For’ header as its value, depending on the value set for Use Client IP in Header. | none |
| `--lslb-ping-interval` | Number of seconds between pings.  Defaults to 10.  0 disables pings. | `10` |
| `--lslb-ping-path` | The ping path to use if pinging. | `/` |
| `--lslb-ping-smart-factor` | How much to multiply ping-interval by between idle pings.  0 disables (default), 1 uses ping interval, 2 doubles ping interval, etc.  A non-zero value detects traffic and suppresses pings if already busy. | `0` |
| `--lslb-session-id` | The session ID string used to extract the session ID from the cookie, query string and URL path parameter. | `JSESSIONID` |
| `--lslb-sess-timeout` | The number of seconds before a session is timed out. | `600` |
| `--lslb-show-backend` | If turned on, there will be a response header added with the  “x-lsadc-backend” title and a value which is a concatenation of the cluster name and the backend IP and port. | `false` |
| `--lslb-strategy` | A number representing the load balancing strategy: 0 = Least-load, 1 = Round-robin, 2 = Least-session, 3 = Faster-response, 4 = Failover | `0` (least-load) |

### Metrics Specific Arguments

The following are addigional LiteSpeed Ingress Controller Arguments used specifically to generate and use Prometheus specific metrics using the built-in exporter.

| Name | Description | Value |
| - | - | - |
| `--enable-metrics` | Whether the built-in Prometheus exporter is activated.  Enable by setting to true. | `false` |
| `--install-prometheus` | Whether Prometheus should be installed on this pod.  Enable by setting to true. | `false` |
| `--metrics-evaluation-interval` | How often Prometheus should evaluate the data (in time format). | `1m` |
| `--metrics-scrape-interval` | Specify how often Prometheus should scrape the .rtreport file (in time format). | `1m` |
| `--metrics-service-port` | The port to be used to access metrics, if enabled.  0 does not expose it outside the pod. | `0` |
| `--metrics-service-target-port` | The port to be used to access metrics, within the pod, if enabled.  This is the reserved port and is rarely changed. | `9936` |
| `--prometheus-port` | The port that will be exported to use Prometheus, if installed.  | '9090' |
| `--prometheus-remote-password` | The prometheus remote_write password.  Often your Grafana Prometheus Metrics API Key. | none |
| `--prometheus-remote-url` | The prometheus remote_write url.  Often your Grafana Prometheus Metrics service. | none |
| `--prometheus-remote-user` | The prometheus remote_write username.  Often your Grafana Prometheus Metrics username (a number). | none |
| `--prometheus-target-port` | The port that will be used within the pod for Prometheus, if installed. | `9091` |


## Troubleshooting

Find more information about how to deal with common errors related to Bitnami’s Helm charts in [this troubleshooting guide](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues).

### Setting security for your namespace

If log indicates an error accessing the secret, something like this: `Error accessing license secret: kube-system/ls-k8s-webadc: secrets "ls-k8s-webadc" is forbidden: User "system:serviceaccount:default:ls-k8s-webadc" cannot get resource "secrets" in API group "" in the namespace "kube-system"`, you may need to grant security to your namespace.

Typically this is done as follows:

```bash
$ kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default -n NAMESPACE
```

### Getting the Pod Name

To do any troubleshooting you'll need the full name of the pod.  This is obtained by running:

        kubectl get pods -n kube-system -o wide

Note that we recommend running the wide version of the command so that you can see not only the names by the nodes and addresses of the pod.

The name of the LiteSpeed Kubernetes Ingress controller pod is ls-k8s-webadc-SUFFIX.  For example: `ls-k8s-webadc-5b6cb78b89-qdhjx`

### Pod Status

Sometimes the problems are described in a simple pod description.  For example:

        kubectl describe pod ls-k8s-webadc-5b6cb78b89-qdhjx >desc.log

You can examine desc.log at your lieisure or it may be requested by LiteSpeed tech support.

### Logs

As with most Kubernetes processes, the best troubleshooting technique is to examine the log.  This is done by getting a list of pods:

Then getting the log for the .  For example:

        kubectl logs ls-k8s-webadc-5b6cb78b89-qdhjx > pod.log

You can then examine pod.log at your leisure or it may be requested by LiteSpeed tech support.

### Errors accessing after deletion

You may see errors accessing service nodes if you just delete the service and attempt to re-create it right away.  You should delete all services and pods, wait until they have terminated and are gone, and then re-create them.


## Notable changes

### 0.2.5 June 25, 2023
- [BugFix] Fixed bugs which kept --default-tls-secret from working correctly.
- [BugFix] Verify ZeroConf worker is not busy before it is deleted.
- [BugFix] Fixed bugs keeping wildcard domain names from being recognized.
- [Feature] 3.1 updates including QUIC v2.

### 0.2.4 April 6, 2023
- [BugFix] Fix a memory violation when data is taken from cache and the server is quite busy.
- [BugFix] Fix a memory leak processing SSL data.
- [BugFix] Fix a small bug in handling multiple headers with the same name.

### 0.2.3 January 17, 2023
- [Feature] HTTP/3 support.  To enable it you must specify in helm `--set options service.ports.http3=443,service.targetPorts.http3=443,containerPorts.http3=443`.
- [Feature] Gateway support extended feature in HTTPRoute, `spec.route.method` which supports matching HTTP method (GET, POST, etc.).
- [Update] Updated all code to operate correctly in the 0.6.0 beta environment.
- [BugFix] Gateway URLRewrite is properly applied.
- [BugFix] Detect when small change between selections results in incorrect worker applied.

### 0.2.2 December 15, 2022
- [Feature] Added support for a number of Gateway HttpRoute Extended Features including:
  - Matches: `Path`, `Type`: `RegularExpression` where PCRE compatible regular expressions are supported
  - Filters:
    - `RequestRedirect`: New features include `Scheme`, `Hostname`, `Path`, `Port` and `StatusCode`.  `Path` can specify a `Type` of `ReplaceFullPath` (an absolute path) or `ReplacePrefixMatch` (a path which will add subdirectories), either of which can include PCRE regular expression replacement strings.
    - `URLRewrite`: `Hostname` and `Path`.  `Hostname` can include a port and `Path` can specify a `Type` of `ReplaceFullPath` (an absolute path) or `ReplacePrefixMatch` (a path which will add subdirectories).
- [Note] You can no longer use the released set of Gateway CRDs to run Gateway until the beta is released.  The Litespeed Ingress Controller uses the latest beta definitions and should be installed using the `./gateway-load.sh` in the samples package and unloaded with `./gateway-unload.sh`.

### 0.2.1 December 2, 2022
- [Improvement] Support detecting the load of the Gateway CRDs after the controller is loaded.  However, Gateway CRDs should not be unloaded without unloading the controller.
- [Improvement] Additional changes for Kubernetes Gateway v1beta1.
- [Bug Fix] Fixed a memory leak in normal operations.

### 0.2.0 November 10, 2022
- [Feature] Kubernetes Gateway API support.  See https://gateway-api.sigs.k8s.io/ for a full description of the feature.
- [Bug Fix] Adjusted helm to allow proper deletion of configmaps.
- [Bug Fix] Support either controller name or ingress class name as the ingress class name in annotations which addresses cert-manager issue.
- [Bug Fix] Fixed a bug in priority management.

### 0.1.30 September 30, 2022
- [Bug Fix] Merged in latest load balancer fixes to address licensing and a memory leak in HTTP/3.

### 0.1.29 September 16, 2022
- [Improvement] Helm install includes support for auto-scaling.
- [Improvement] Caching is enabled by default

### 0.1.28 August 26, 2022
- [Bug Fix] Fixed a deadlock bug which resulted in a delay in the implementation and activation of Ingress configuration updates.
- [Bug Fix] Do not require an IngressClass specification for the default IngressClass to operate correctly.

### 0.1.27 August 23, 2022
- [Bug Fix] Proper support for multiple backends with different contexts for the same domain.
- [Bug Fix] Support PathType ImplementationSpecific identically to PathPrefix to allow cert-manager to work correctly for automatic certificate verification.

### 0.1.26 June 21, 2022
- [Feature] New `prometheus-remote` Prometheus arguments which can be used to have Prometheus push stats to Grafana Cloud.
- [Feature] Removed all references to v1beta1 to support Kubernetes v1.22 and above.
- [Bug Fix] Fixed helm deployment.

### 0.1.25 June 17, 2022
- [Feature] There is now a built-in Prometheus metrics exporter.  Must be enabled by the Ingress Controller argument `enable-metrics` to be activated.  Prometheus can be installed on the service pod as well using the argument `install-prometheus`.
- [Feature] Ingress Controller argument `--run-before-lb='commands'` can specify any number of commands that will be run before the load balancer starts.
- [Feature] New Ingress Controller argument `config-service-port` can be used to expose the config port without the use of helm configuration.
- [Bug Fix] Licensing documented and functions correctly.
- [Bug Fix] Correctly apply secrets even for secrets missing a name.
- [Bug Fix] Correctly apply command line `lslb-config-map-prefix`

### 0.1.24 May 24, 2022
- [Feature] Added regular expressions to advanced deployments with the new annotation `litespeedtech.com/hostx.servicex.weight`
- [Bug Fix] For an advanced deployment, if you specify the same host twice, it will correctly use the first one rather than generate an incorrect ZeroConf definition.
- [Bug Fix] If you change the definition, the replaced definition will be not cached for new session use, though existing ones will still finish correctly.

### 0.1.23 May 19, 2022
- [Feature] Red/Blue and Canary deployments using annotations.
- [Bug Fix] context_list is properly passed in ZeroConf between Go program and load balancer resulting in contexts now working correctly.
- [Bug Fix[ A missing exact context entry is now correctly added into contexts.
- [Bug Fix] Use and document vhostPerDomain correctly.

### 0.1.22 May 6, 2022
- [Feature] WebAdmin interface is now available including Real-Time Stats and template WebADC configuration.  Template support provides availability to the Web Application Firewall.
- [Feature] Optional support for configuration port in helm definition (service.ports.config).
- [Bug Fix] Reduce restarts within health checks.

### 0.1.21 Apr 15, 2022
- [Feature] Support both Nginx and generic Rewrite annotations.
- [Bug Fix] Correctly support multiple domains for a SSL certificate.

### 0.1.20 Mar 14, 2022
- [Feature] Support Prefix and Exact path types as well as the Litespeed ImplementationSpecific type.
- [Feature] Added controller parameter `--lslb-replace-conf` which allows replacement of any number of WebADC lslbd_config.xml parameters.
- [Bug Fix] A number of path specific bugs have been fixed.
- [Bug Fix] Performance improvements through better caching of domain/path information.

### 0.1.19 Jan 26, 2022
- [Bug Fix] Fixed bug in detection of Not Found when only child domains are specified in Ingress specifications.
- [Bug Fix] Fixed bug in locking resulting in unnecessary performance loss.

### 0.1.18 Jan 20, 2022
- [Feature] Full support for separate backends for a single domain by path.
- [Feature] Added examples tarball to helm distribution.
- [Bug Fix] Increased helm default timeouts so that a slow backend won't cause the load balancer to go into a crash loop.

### 0.1.17 Dec 28, 2021
- [Bug Fix] Fixed bug introduced in 0.1.16 where only the default backend is used if there are multiple backends.

### 0.1.16 Dec 23, 2021
- [Feature] Full support for new load balancer features including the Fail-over strategy to improve availability, and Smart ping to reduce network traffic.
- [Feature] Support path as well as domain and properly report path not found (404) for a root with no path defined (subdirectories only).
- [Feature] Support for wildcarded domains.
- [Feature] Report additional troubleshooting info to the kubernetes log about a failure to bring up lslb
- [Bug Fix] When testing whether WebADC is up, ping local host rather than random backend.
- [Bug Fix] When testing whether WebADC is up, use domain rather than IP address (as is required in ZeroConf).
- [Bug Fix] Do not crash when using a root path along with a non-root path.

### 0.1.15 Nov 22, 2021
- [Bug Fix] Turned off debugging in WebADC.

### 0.1.14 Nov 18, 2022
- [Feature] Added LiteSpeed WebADC load balancer configuration controls.
- [Feature] Added LiteSpeed WebADC cache location configuration control.
- [Bug Fix] Support TLS for site where there is a front end SSL configuration, even if there is no backend SSL configuration.

### 0.1.13 Nov 12, 2022
- [Bug Fix] Fixed a crash which occurred if you have no ingress definitions defined with secrets at startup and have not defined a default secret.
- [Bug Fix] Fixed a helm packaging issue which resulted in the wrong version being pulled at the remote.

### 0.1.12 Nov 10, 2021
- [Bug Fix] Fix a bug introduced in 0.1.11 where HTTPS would still be tried to be supported an HTTP only ingress.
- [Bug Fix] Fix a bug where the port and target port are different, did not accept the service.

### 0.1.11 Nov 8, 2021
- If an ingress secret is not found, do not skip the ingress, but only support HTTP.
- Each helm release will now specify the version number of the image it wants.

### 0.1.10 Nov 3, 2021
- No longer require a backend TLS secret to allow TLS to function at all.

### 0.1.9 Nov 1, 2021
- Fix bug in termination so it is faster and cleans up addresses in Ingress classes.
- Support the ingress class Annotation `kubernetes.io/ingress.class` as well as the ingress class definition.

### 0.1.8 Oct 28, 2021
- Fix bug in `update-status` where status updates were being done for controllers not matching the ingress class
- Update LiteSpeed Web ADC image so that it uses the latest fixes for TLS secrets.

### 0.1.7 Oct 26, 2021
- Support for the `update-status` variable which is important in working in cloud environments.
- Proper support for SSL definitions outside of the default
- Support to a staging version with test code if needed.

### 0.1.6 Oct 15, 2021
- Automatic use of the overall namespace for the license files if not specified.
- Updated doc including security doc.

### 0.1.5 Oct 14, 2021
- Proper helm support for a LiteSpeed ADC override parameters
- Updated doc.

### 0.1.4 Oct 14, 2021
- Use of the correct Docker repo
- Updated doc.

### 0.1.3 Oct 13, 2021
- Separation of helm from other code
- Use of this README.md as the source of primary documentation.

### 0.1.2
- Fixed a bug in HTTPS support.
- Updated helm templates.
- Updated doc.

### 0.1.1
- Both regular and helm support for user specified default backend.  In the helm version, helm will deploy the default backend as  documented in the Default Backend Parameters table.