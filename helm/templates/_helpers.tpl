{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
Truncate at 63 chars characters due to limitations of the DNS system.
*/}}
{{- define "hello-world.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define the docker image.
If .Values.image.registry is defined, dockerImage: {{.Values.image.registry}}/{{.Values.image.path}}:{{.Values.image.tag}}
If .Values.image.registry is "-", dockerImage: {{.Values.image.path}}:{{.Values.image.tag}}
*/}}

{{- define "hello-world.image" -}}
    {{- if eq .Values.image.registry "-" }}
        {{- printf "%s:%s" .Values.image.path (default "latest" .Values.image.tag) -}}
    {{else}}
        {{- printf "%s/%s:%s" .Values.image.registry .Values.image.path (default "latest" .Values.image.tag) -}}
    {{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hello-world.fullname" -}}
{{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- if contains $name .Release.Name -}}
        {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default chart name including the version number
*/}}
{{- define "hello-world.chart" -}}
{{- $name := (include "hello-world.name" .) -}}
{{- printf "%s-%s" $name .Chart.Version | replace "+" "_" -}}
{{- end -}}


{{/*
Define labels which are used throughout the chart files
*/}}
{{- define "hello-world.labels" -}}
com.hello-world.application: {{ .Values.image.applicationNameLabel }}
com.hello-world.service: {{ .Values.image.serviceNameLabel }}
chart: {{ include "hello-world.chart" . }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{- end -}}

{{/*
Define labels which are used throughout the chart files
*/}}
{{- define "hello-world.labels.selector" -}}
com.hello-world.application: {{ .Values.image.applicationNameLabel }}
com.hello-world.service: {{ .Values.image.serviceNameLabel }}
release: {{ .Release.Name }}
{{- end -}}

{{/*
Returns the service name which is by default fixed (not depending on release).
It can be prefixed by the release if the service.prefixWithHelmRelease is true
*/}}
{{- define "hello-world.service.name" -}}
{{- if eq .Values.service.prefixWithHelmRelease true -}}
    {{- $name := .Values.service.name | trunc 63 | trimSuffix "-" -}}
    {{- printf "%s-%s" .Release.Name $name -}}
{{else}}
    {{- .Values.service.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

