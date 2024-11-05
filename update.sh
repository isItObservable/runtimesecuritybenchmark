#!/usr/bin/env bash

################################################################################
### Script deploying the Observ-K8s environment
### Parameters:
### Clustern name: name of your k8s cluster
### dttoken: Dynatrace api token with ingest metrics and otlp ingest scope
### dturl : url of your DT tenant wihtout any / at the end for example: https://dedede.live.dynatrace.com
### type: defines which solution would be deployed in the cluster ( falco, tetragon or kubearmor)
################################################################################


### Pre-flight checks for dependencies
if ! command -v jq >/dev/null 2>&1; then
    echo "Please install jq before continuing"
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "Please install git before continuing"
    exit 1
fi


if ! command -v helm >/dev/null 2>&1; then
    echo "Please install helm before continuing"
    exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Please install kubectl before continuing"
    exit 1
fi
echo "parsing arguments"
while [ $# -gt 0 ]; do
  case "$1" in
       --previous)
        OLD="$2"
        shift 2
        ;;
       --type)
        TYPE="$2"
        shift 2
        ;;
  *)
    echo "Warning: skipping unsupported option: $1"
    shift
    ;;
  esac
done
echo "Checking arguments"

 if [ -z "$TYPE" ]; then
   echo "Error: type is  not set!"
   exit 1
 fi
 if [ -z "$OLD" ]; then
   echo "Error: type is  not set!"
   exit 1
 fi

# Falco
if [  "$OLD" = 'falco' ]; then
   kubectl delete -f opentelemetry/openTelemetry-manifest_statefulset_falco.yaml
   helm uninstall falco -n falco
else
  if [  "$OLD" = 'tetragon' ]; then
      kubectl delete -f opentelemetry/openTelemetry-manifest_statefulset_tetragon.yaml
      kubectl delete -k tetragon
      helm uninstall tetragon/policicies -n tetragon
  else
     if [  "$OLD" = 'kubearmor' ]; then
        kubectl delete -f opentelemetry/openTelemetry-manifest_statefulset_kubearmor.yaml
        kubectl delete -k kubearmor/policies
        helm uninstall kubearmor-operator -n kubearmor
     else
       if [ "$OLD" = 'tracee' ]; then
          kubectl delete -f  opentelemetry/openTelemetry-manifest_statefulset_tracee.yaml
          kubectl delete -f tracee/servicemetric.yaml -n tracee
          kubectl delete -k tracee/policy
          helm uninstall tracee -n tracee
        else
          kubectl delete -f opentelemetry/openTelemetry-manifest_statefulset_kubearmor.yaml
        fi
      fi
  fi
fi
# Falco
if [  "$TYPE" = 'falco' ]; then

  echo " Installing Falco"
  helm repo add falcosecurity https://falcosecurity.github.io/charts
  helm repo update
  helm install falco \
        --set driver.kind=modern_ebpf \
        --set tty=true \
        --set collectors.kubernetes.enabled=true \
        --set falco.json_output=true \
        --set metrics.enabled=true \
        --set falcosidekick.enabled=true  \
        --set falcosidekick.config.dynatrace.apiurl=$DTURL/api \
        --set falcosidekick.config.dynatrace.apitoken=$DTTOKEN  \
        --set falcosidekick.config.dynatrace.minimumpriority=debug\
        --set falcosidekick.config.dynatrace.checkcert=false \
        --set falcosidekick.webui.enabled=true \
         --namespace falco --create-namespace falcosecurity/falco

  kubectl apply -f opentelemetry/openTelemetry-manifest_statefulset_falco.yaml
else
  if [  "$TYPE" = 'tetragon' ]; then
    echo "Install Tetragon"
    # tetragon                                                                                                                                                                                    --set-string controller.podAnnotations."prometheus\.io/port"="10254"
    helm repo add cilium https://helm.cilium.io
    helm repo update
    helm install tetragon cilium/tetragon -n tetragon --create-namespace -f tetragon/values.yaml

    kubectl apply -f opentelemetry/openTelemetry-manifest_statefulset_tetragon.yaml
    kubectl apply -k tetragon/policicies

  else
    if [  "$TYPE" = 'kubearmor' ]; then
    # kubearmor
    echo "installing KuberArmor"
    helm repo add kubearmor https://kubearmor.github.io/charts
    helm repo update kubearmor

    helm upgrade --install kubearmor-operator kubearmor/kubearmor-operator -n kubearmor --create-namespace -f kubearmor/values.yaml
    kubectl apply -f kubearmor/kubeArmorConfig.yaml

    kubectl apply -f opentelemetry/openTelemetry-manifest_statefulset_kubearmor.yaml
    kubectl apply -k kubearmor/policies

    else
       if [ "$TYPE" = 'tracee' ]; then
         helm repo add aqua https://aquasecurity.github.io/helm-charts/
         helm repo update
         helm install tracee aqua/tracee --namespace tracee --create-namespace
         kubectl apply -k tracee/policy
         kubectl apply -f tracee/servicemetric.yaml -n tracee
         kubectl apply -f  opentelemetry/openTelemetry-manifest_statefulset_tracee.yaml
       else
          echo "No security solution deployed"
          kubectl apply -f opentelemetry/openTelemetry-manifest_statefulset_kubearmor.yaml
       fi

    fi
  fi
fi




