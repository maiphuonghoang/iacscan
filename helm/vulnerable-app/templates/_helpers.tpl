{{/*
Return the full name of the application
*/}}
{{- define "vulnerable-app.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the common labels used for this chart
*/}}
{{- define "vulnerable-app.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Return the selector labels used to identify the pods
*/}}
{{- define "vulnerable-app.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Return the service account name
*/}}
{{- define "vulnerable-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "vulnerable-app.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
default
{{- end -}}
{{- end -}}
