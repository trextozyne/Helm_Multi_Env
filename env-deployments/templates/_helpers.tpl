{{- define "env.labels" -}}
app: react-ui
env: {{ .Values.app.env }}
{{- end -}}