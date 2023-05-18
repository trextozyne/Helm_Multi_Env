1. Create Helm Chart for your project
  ```shell
    helm create env-deployments
    Creating env-deployments
  ```
  Then remove unnecessary files from the charts i.e Ingress, ServiceAccounts
2. Create Values(common data i.e. replicas) in [values.yaml](./env-deployments/values-dev.yaml)
  ```yaml
   app:
   replicas: 1
  ```
3. Use the values in the files that require them i.e [deployment.yaml](./env-deployments/templates/deployment.yaml)
  ```yaml
    spec:
    replicas: {{.Values.app.replicas}}
  ```
4. Use [helpers](./env-deployments/templates/_helpers.tpl) the most commonly repeated data in a yaml file, that can be used to represent the environment i.e.
  ```yaml
    labels:
      app: react-ui <==common
      env: dev      <==common
  ```
  and convert them to helm chart start by defining the parent variable in values
  ```yaml
   app:
    ...
   env: dev
  ```
  Then in [helpers](./env-deployments/templates/_helpers.tpl),
  ```tpl
    {{- define "env.labels" -}}
    app: react-ui
    env: {{ .Values.app.env }} #here the environment values is set
    {{- end -}}
  ```
  and use ```include``` to use it everywhere necessary
  ```yaml
    labels:
    {{- include "env.labels" . | nindent 4 }}
    # where the nindent does the appropriate alignment by providing with its tab space
  ```
5. I check if what I've written is valid
   ```shell
     helm template dev-template -f ./env-deployments/values-dev.yaml ./env-deployments 
   ```
   If there exists any errors, add ```--debug``` to verbose the error in details
   ```shell
     helm template dev-template -f ./env-deployments/values-dev.yaml ./env-deployments --debug
   ```
6. Adding Conditions to Helm-Charts
   I noticed when I ran the hemp template, it was showing HPA, but its not required in DEV stage, so I need to add a condeition
   In values, I did: 
  ```yaml
    hpa:
    enabled: false
  ```
   then in [hpa.yaml](./env-deployments/templates/hpa.yaml), I add a conditional loop
  ```yaml
  # the condition check true or false and decides on including it or not
  ---
  {{- if .Values.hpa.enabled -}}
    ...
  {{- end -}}
  ```
7. Using a helm function called toYaml, i can take a whole block of yaml code and use it when i need it i.e
   Add this portion to [values.yaml](./env-deployments/values-dev.yaml)
  ```yaml
   app:
    ...
   resources:
      limits:
      cpu: 0.2
      memory: 500Mi
      requests:
         cpu: 0.2
         memory: 500Mi
  ```
   and the resource section of the [deployment.yaml](./env-deployments/templates/deployment.yaml) file use:
  ```yaml
    resources:
    {{- toYaml .Values.app.resources | nindent 12 }}
  ```
8. Also, I can variabelize images just in scenario when diff. images are used: 
9. I can variabelize some part of the HPA as it would only be used in the [values-prod.yaml](./env-deployments/values-prod.yaml)
  ```yaml
    spec:
    maxReplicas: 10
    minReplicas: 4
      ...
    targetCPUUtilizationPercentage: 50
  ```
  ```yaml
   maxReplicas: {{ .Values.hpa.maxReplicas }}
   minReplicas: {{ .Values.hpa.minReplicas }}
    ...
   targetCPUUtilizationPercentage: {{ .Values.hpa.targetCPUUtilizationPercentage }}
  ```
10. Now running helm for the different values, redirecting and outputting them to a file:
  ```shell
     helm template dev-template -f ./env-deployments/values-dev.yaml ./env-deployments > dev.deployment.yaml
   ```