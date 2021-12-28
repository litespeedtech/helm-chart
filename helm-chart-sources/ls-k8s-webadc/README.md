LiteSpeed WebADC in Kubernetes
==============================

The LiteSpeed Kubernetes ADC controller is a specially designed Kubernetes application and uses the LiteSpeed WebADC controller to operate as an Ingress Controller and Load Balancer to properly manage your traffic on your Kubernetes cluster.

It is based on the [nginx](https://github.com/kubernetes-retired/contrib/tree/master/ingress/controllers/nginx) and [nghttpx](https://github.com/zlabjp/nghttpx-ingress-lb) ingress controllers.


## Introduction

This chart bootstraps a LiteSpeed Web ADC Ingress deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Prerequisites

- Kubernetes 1.19+
- Helm 3.1.0

## Selecting a Namespace

The default namespace is not generally where new pods and services are loaded into.  The `kube-system` namespace is the default for most system pods and a load balancer can be considered one of those.  However, your environment may have restrictions on using `kube-system` so you may choose to use a non-system namespace like `ls-k8s-webadc` to have the namespace match the other names in the system.

Namespace is required on most Kubernetes commands so this document will use the name NAMESPACE to indicate the namespace you have selected.

## Adding a License

The LiteSpeed Kubernetes ADC controller uses the LiteSpeed WebADC engine which is a licensed program product.  To use it you must obtain either a `trial.key` file for a trial or a `license.key` and `serial.no` files for a full license.  The Docker image requires that you define a generic secret to successfully run the software.

For a trial, place the trial.key file in the default directory and run:

```bash
$ kubectl create secret generic -n NAMESPACE ls-k8s-webadc --from-file=trial=./trial.key
```

For a full license place both files in the default directory and run:

```bash
$ kubectl create secret generic -n NAMESPACE ls-k8s-webadc --from-file=license=./license.key --from-file=serial=./serial.no
```

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


### LiteSpeed WebADC Ingress Controller parameters

| Name                          | Description                                                                                                                                        | Value                              |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `image.registry`              | LiteSpeed WebADC Ingress Controller image registry                                                                                                 | `docker.io`                        |
| `image.repository`            | LiteSpeed WebADC Ingress Controller image repository                                                                                               | `litespeedtech/ls-k8`              |
| `image.tag`                   | LiteSpeed WebADC Ingress Controller image tag                                                                                                      | `latest`                           |
| `image.pullPolicy`            | LiteSpeed WebADC Ingress Controller image pull policy                                                                                              | `Always`                           |
| `image.pullSecrets`           | Specify docker-registry secret names as an array                                                                                                   | `[]`                               |
| `defaultBackendService`       | Default 404 backend service.                                                                                                                       | `""`                               |
| `publishService.enabled`      | Set the endpoint records on the Ingress objects to reflect those on the service                                                                    | `false`                            |
| `publishService.pathOverride` | Allows overriding of the publish service to bind to                                                                                                | `""`                               |
| `scope.enabled`               | Limit the scope of the controller. Defaults to `.Release.Namespace`                                                                                | `false`                            |
| `command`                     | Override default container command (useful when using custom images)                                                                               | `[]`                               |
| `args`                        | Override default container args (useful when using custom images)                                                                                  | `[]`                               |
| `extraArgs`                   | Additional command line arguments.  Without leading dashes, comma separated, in quotes and curly braces.  See below for the full list.             | `{}`                               |
| `extraEnvVars`                | Extra environment variables to be set on LiteSpeed WebADC Ingress container                                                                        | `[]`                               |
| `extraEnvVarsSecret`          | Name of a existing Secret containing extra environment variables                                                                                   | `""`                               |


### LiteSpeed WebADC Ingress deployment / daemonset parameters

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
| `hostNetwork`                                       | If the LiteSpeed WebADC deployment / daemonset should run on the host's network namespace               | `false`        |
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
| `defaultBackend.extraArgs`                          | Additional command line arguments to pass to LiteSpeed WebADC container                   | `{}`                   |
| `defaultBackend.containerPort`                      | HTTP container port number                                                                | `80`                   |
| `defaultBackend.serverBlockConfig`                  | LiteSpeed WebADC backend default server block configuration                               | `""`                   |
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


### Metrics parameters

| Name                                      | Description                                                                   | Value       |
| ----------------------------------------- | ----------------------------------------------------------------------------- | ----------- |
| `metrics.enabled`                         | Enable exposing Controller statistics                                         | `false`     |
| `metrics.service.type`                    | Type of Prometheus metrics service to create                                  | `ClusterIP` |
| `metrics.service.port`                    | Service HTTP management port                                                  | `9913`      |
| `metrics.service.annotations`             | Annotations for the Prometheus exporter service                               | `{}`        |
| `metrics.serviceMonitor.enabled`          | Create ServiceMonitor resource for scraping metrics using PrometheusOperator  | `false`     |
| `metrics.serviceMonitor.namespace`        | Namespace in which Prometheus is running                                      | `""`        |
| `metrics.serviceMonitor.interval`         | Interval at which metrics should be scraped                                   | `30s`       |
| `metrics.serviceMonitor.scrapeTimeout`    | Specify the timeout after which the scrape is ended                           | `""`        |
| `metrics.serviceMonitor.selector`         | ServiceMonitor selector labels                                                | `{}`        |
| `metrics.prometheusRule.enabled`          | Create PrometheusRules resource for scraping metrics using PrometheusOperator | `false`     |
| `metrics.prometheusRule.additionalLabels` | Used to pass Labels that are required by the Installed Prometheus Operator    | `{}`        |
| `metrics.prometheusRule.namespace`        | Namespace which Prometheus is running in                                      | `""`        |
| `metrics.prometheusRule.rules`            | Rules to be prometheus in YAML format, check values for an example            | `[]`        |


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

If you have a need for additional containers to run within the same pod as the LiteSpeed WebADC Ingress Controller (e.g. an additional metrics or logging exporter), you can do so via the `sidecars` config parameter. Simply define your container according to the Kubernetes container spec.

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


## LiteSpeed Kubernetes ADC Controller Arguments

The LiteSpeed Kubernetes ADC Controller arguments are specified in helm with the `extraArgs` list above or if you are creating or modifying your own .yaml files in `spec/template/spec/containers/args`.  In yaml files an initial leading dash is required for repeating parameters and the second double leading dash is required for all controller arguments.  When using helm `extraArgs` do not use leading dashes and comma separate parameters.

| Name | Description | Value |
| - | - | - |
| `--allow-internal-ip` | Allows the use address of type NodeInternalIP when fetching the external IP address.  This is the workaround for the cluster configuration where NodeExternalIP or NodeLegacyHostIP is not assigned or cannot be used. | `false` |
| `--default-tls-secret` | Name of the Secret that contains TLS server certificate and secret key to enable TLS by default.  For those client connections which are not TLS encrypted, they are redirected to https URI permanently. | `NAMESPACE/ls-k8s-webadc.com` |
| `--deferred-shutdown-period` | How long the controller waits before actually starting shutting down when it receives shutdown signal. Specified as a Kubernetes duration. | `0` (immediate) | 
| `--endpoint-slices` | Get endpoints from EndpointSlice resource instead of Endpoints resource. | `false` |
| `--healthz-port` | Port for healthz endpoint.  Can be any open port. | `11972` |
| `--ingress-class-controller` | The name of IngressClass controller for this controller.  This is the value specified in `IngressClass.spec.controller.` | `litespeedtech.com/lslbd` |
| `--lslb-cache-store-path` | Specifies the directory in the container to hold cached images.  This directory must be mounted and pre-created. | Default location
| `--lslb-debug` | Set to true if you want LSLB tracing enabled on startup. | `false` |
| `--lslb-dir` | The directory in the Docker image where the LiteSpeed Web ADC is installed, the default of `/usr/local/lslb` is the default ADC directory. | `/usr/local/lslb` |
| `--lslb-enable-ocsp-stapling` | Enable OCSP stapling on ADC server. | `false` |
| `--lslb-http-port` | Port to listen to for HTTP (non-TLS) requests.  Specifying 0 disables HTTP port. | `80` |
| `--lslb-https-port` | Port to listen to for HTTPS (TLS) requests.  Specifying 0 disables HTTPS port. | `443` |
| `--lslb-license-secret` | The required secret to be used to identify the LS WebADC license file(s). | `NAMESPACE/ls-k8s-webadc` |
| `--lslb-max-conn` | Sent in the ZCUP command, lets you manually set it.  Set for all servers if set here.  | `1000` |
| `--lslb-priority` | Sent in the ZCUP command, only useful when the strategy is Fail-over, min value 0, default 100, max value 255. Set for all servers if set here. | `100` |
| `--lslb-wait-timeout` | Number of seconds to wait for lslb to start listening for ZeroConf events. | `10` |
| `--lslb-zeroconf-password` | The password to be used to access zero conf.  The default is `zero` and changing it is documented in [ZeroConf](https://docs.litespeedtech.com/products/lsadc/zeroconf/). | `zero` |
| `--lslb-zeroconf-port` | The port to be used to access zero conf in LiteSpeed Web ADC. | `7099` |
| `--lslb-zeroconf-user` | The user to be used to access zero conf.  Changing it is documented in [ZeroConf](https://docs.litespeedtech.com/products/lsadc/zeroconf/). | `zero` |
| `--profiling` | Enable profiling at the health port.  It exposes /debug/pprof/ endpoint. | `true` |
| `--publish-service` | Specify namespace/name of Service whose hostnames/IP addresses are set in Ingress resource instead of addresses of Ingress controller Pods.  Takes the form namespace/name. | `NAMESPACE/ls-k8s-webadc` |
| `--reload-burst` | Reload burst that can exceed reload-rate. | `1` |
| `--reload-rate` | Rate (QPS) of reloading LiteSpeed WebADC configuration to deal with frequent backend updates in a single batch. | `1.0` |
| `--v` |  Sets info logging.  --v=4 is the most verbose. | `2` |
| `--update-status` | Update the load-balancer status of Ingress objects this controller satisfies.  Requires publish-service to be specified. | `true` |
| `--watch-namespace` | The namespace to watch for Ingress events. | All namespaces |

### Load Balancing Controller Arguments

There are additional LiteSpeed Kubernetes ADC Controller arguments which are specific to modifying the operation of the load balancer specifically.  Most noteworthy are the `--lslb-affinity` and `--lslb-strategy` arguments but all of the following are important in modifying the load balancing of the controller.  Note that they are specifically designed to give you the features available in the Load Balancer configuration, Clusters tab.

| Name | Description | Value |
| - | - | - |
| `--lslb-affinity` | Set to false for no affinity (stateless) or true for affinity (stateful). | `true` |
| `--lslb-insert-cookie` | If specified, this is the name of a cookie to be inserted in the stream. | Do not insert cookie |
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

The name of the LiteSpeed Kubernetes ADC controller pod is ls-k8s-webadc-SUFFIX.  For example: `ls-k8s-webadc-5b6cb78b89-qdhjx`

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
### 0.1.17
- [Bug Fix] Fixed bug introduced in 0.1.16 where only the default backend is used if there are multiple backends.

### 0.1.16
- [Feature] Full support for new load balancer features including the Fail-over strategy to improve availability, and Smart ping to reduce network traffic.
- [Feature] Support path as well as domain and properly report path not found (404) for a root with no path defined (subdirectories only).
- [Feature] Support for wildcarded domains.
- [Feature] Report additional troubleshooting info to the kubernetes log about a failure to bring up lslb
- [Bug Fix] When testing whether WebADC is up, ping local host rather than random backend.
- [Bug Fix] When testing whether WebADC is up, use domain rather than IP address (as is required in ZeroConf).
- [Bug Fix] Do not crash when using a root path along with a non-root path.

### 0.1.15
- [Bug Fix] Turned off debugging in WebADC.

### 0.1.14
- [Feature] Added LiteSpeed WebADC load balancer configuration controls.
- [Feature] Added LiteSpeed WebADC cache location configuration control.
- [Bug Fix] Support TLS for site where there is a front end SSL configuration, even if there is no backend SSL configuration.

### 0.1.13
- [Bug Fix] Fixed a crash which occurred if you have no ingress definitions defined with secrets at startup and have not defined a default secret.
- [Bug Fix] Fixed a helm packaging issue which resulted in the wrong version being pulled at the remote.

### 0.1.12
- [Bug Fix] Fix a bug introduced in 0.1.11 where HTTPS would still be tried to be supported an HTTP only ingress.
- [Bug Fix] Fix a bug where the port and target port are different, did not accept the service.

### 0.1.11
- If an ingress secret is not found, do not skip the ingress, but only support HTTP.
- Each helm release will now specify the version number of the image it wants.

### 0.1.10
- No longer require a backend TLS secret to allow TLS to function at all.

### 0.1.9
- Fix bug in termination so it is faster and cleans up addresses in Ingress classes.
- Support the ingress class Annotation `kubernetes.io/ingress.class` as well as the ingress class definition.

### 0.1.8
- Fix bug in `update-status` where status updates were being done for controllers not matching the ingress class
- Update LiteSpeed Web ADC image so that it uses the latest fixes for TLS secrets.

### 0.1.7
- Support for the `update-status` variable which is important in working in cloud environments.
- Proper support for SSL definitions outside of the default
- Support to a staging version with test code if needed.

### 0.1.6
- Automatic use of the overall namespace for the license files if not specified.
- Updated doc including security doc.

### 0.1.5
- Proper helm support for a LiteSpeed ADC override parameters
- Updated doc.

### 0.1.4
- Use of the correct Docker repo
- Updated doc.

### 0.1.3
- Separation of helm from other code
- Use of this README.md as the source of primary documentation.

### 0.1.2
- Fixed a bug in HTTPS support.
- Updated helm templates.
- Updated doc.

### 0.1.1
- Both regular and helm support for user specified default backend.  In the helm version, helm will deploy the default backend as  documented in the Default Backend Parameters table.