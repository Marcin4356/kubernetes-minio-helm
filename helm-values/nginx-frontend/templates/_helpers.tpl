{{- define "nginx-frontend.name" -}}
nginx-frontend
{{- end }}

{{- define "nginx-frontend.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "nginx-frontend.fullname" -}}
{{ printf "%s-%s" .Release.Name (include "nginx-frontend.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
