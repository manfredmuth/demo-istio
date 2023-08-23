{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  used in phase 2-instance
  name of the current mesh
*/}}
{{- define "app.currentmeshname" -}}
{{- if contains "green-mesh" .Values.phase  }}
{{- coalesce .Values.nameGreenmesh "green-mesh" }}
{{- else if contains "red-mesh" .Values.phase  }}
{{- coalesce .Values.nameRedmesh "red-mesh" }}
{{- else if contains "blue-mesh" .Values.phase  }}
{{- coalesce .Values.nameBluemesh "blue-mesh" }}
{{- else }}
{{- printf "none" }}
{{- end }}
{{- end }}

{{/*
  used in phase 2-instance
  name of the other mesh
*/}}
{{- define "app.othermeshname" -}}
{{- if contains "green-mesh" .Values.phase  }}
{{- coalesce .Values.nameRedmesh "red-mesh" }}
{{- else if contains "red-mesh" .Values.phase  }}
{{- coalesce .Values.nameGreenmesh "green-mesh" }}
{{- else }}
{{- printf "none" }}
{{- end }}
{{- end }}


{{/*
  used in phase 2-instance
  namespace of the current mesh
*/}}
{{- define "app.currentmeshsystemnamespace" -}}
{{- if contains "green-mesh" .Values.phase  }}
{{- coalesce .Values.namespaceGreenmeshSystem "green-mesh-system" }}
{{- else if contains "red-mesh" .Values.phase  }}
{{- coalesce .Values.namespaceRedmeshSystem "red-mesh-system" }}
{{- else if contains "blue-mesh" .Values.phase  }}
{{- coalesce .Values.namespaceBluemeshSystem "blue-mesh-system" }}
{{- else }}
{{- printf "none" }}
{{- end }}
{{- end }}

{{/*
  used in phase 2-instance
  cluster name of the current mesh
*/}}
{{- define "app.currentmeshclustername" -}}
{{- if contains "green-mesh" .Values.phase  }}
{{- coalesce .Values.nameClusterGreenmesh "green-cluster" }}
{{- else if contains "red-mesh" .Values.phase  }}
{{- coalesce .Values.nameClusterRedmesh "red-cluster" }}
{{- else if contains "blue-mesh" .Values.phase  }}
{{- coalesce .Values.nameClusterBluemesh "blue-cluster" }}
{{- else }}
{{- printf "none" }}
{{- end }}
{{- end }}

{{/*
  used in phase 2-green-mesh and 3-red-mesh
  cluster name of the current mesh
*/}}
{{- define "app.deploymentnamespace" -}}
{{- if contains "green-mesh" .Values.phase }}
{{- coalesce .Values.namespaceGreenmesh "gm-servicemeshinterconnect" }}
{{- else if contains "red-mesh" .Values.phase }}
{{- coalesce .Values.namespaceRedmesh "gm-servicemeshfederation" }}
{{- else if contains "blue-mesh" .Values.phase }}
{{- coalesce .Values.namespaceBluemesh "gm-federation-aws" }}
{{- else }}
{{- printf "none" }}
{{- end }}
{{- end }}

{{/*
  used in phase 2-green-mesh and 3-red-mesh
  cluster name of the current mesh
*/}}
{{- define "app.othermeshaddress" -}}
{{- if contains "green-mesh" .Values.phase }}
{{- coalesce .Values.addressRedmesh "public-mesh-ingress-istio-system.rhpds-433dee0b4ccaac7b6341df52e43bcc94-0000.us-east.containers.appdomain.cloud" }}
{{- else if contains "red-mesh" .Values.phase }}
{{- coalesce .Values.addressGreenmesh "c271fa80-us-east.lb.appdomain.cloud" }}
{{- else }}
{{- printf "none" }}
{{- end }}
{{- end }}