{{/*
Expand the name of the chart.
*/}}
{{- define "ls-k8s-webadc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ls-k8s-webadc.defaultBackend.fullname" -}}
{{- if .Values.defaultBackend.enabled -}}
{{- if .Values.fullnameOverride }}
{{- printf "%s-default-backend" .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- printf "%s-default-backend" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s-default-backend" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ls-k8s-webadc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ls-k8s-webadc.labels" -}}
helm.sh/chart: {{ include "ls-k8s-webadc.chart" . }}
{{ include "ls-k8s-webadc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ls-k8s-webadc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ls-k8s-webadc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ls-k8s-webadc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper ls-k8s-webadc image name
*/}}
{{- define "ls-k8s-webadc.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper defaultBackend image name
*/}}
{{- define "ls-k8s-webadc.defaultBackend.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.defaultBackend.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "ls-k8s-webadc.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.defaultBackend.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Construct the path for the publish-service.

By convention this will simply use the <namespace>/<controller-name> to match the name of the
service generated.
Users can provide an override for an explicit service they want bound via `.Values.publishService.pathOverride`

*/}}
{{- define "ls-k8s-webadc.publishServicePath" -}}
{{- $defServiceName := printf "%s/%s" .Release.Namespace (include "common.names.fullname" .) -}}
{{- $servicePath := default $defServiceName .Values.publishService.pathOverride }}
{{- print $servicePath | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for PodSecurityPolicy
*/}}
{{- define "ls-k8s-webadc.podSecurityPolicy.apiVersion" -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiGroup for PodSecurityPolicy.
*/}}
{{- define "ls-k8s-webadc.podSecurityPolicy.apiGroup" -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "policy" -}}
{{- else -}}
{{- print "extensions" -}}
{{- end -}}
{{- end -}}

