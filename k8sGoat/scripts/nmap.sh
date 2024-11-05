

ns=$(kubectl get ns -ojson | jq -r --argjson r $RANDOM '.items[$r % length].metadata.name')
podid=""
while [ -z $podid  ] || [  $podid  = "null" ]; do
  echo "Waiting to get pod id"
  podid=$(kubectl get pods -n $ns -ojson | jq -r --argjson r $RANDOM '.items[$r % (length-1)].metadata.name')
  [ -z "$podid" ]  ||  [  $podid  = "null" ] && sleep 10
done

echo "exec on the $podid in $ns"
kubectl exec -ti  $podid -n $ns -- /bin/bash -c "apt-get update && apt-get install nmap && apt-get install iproute2 ;\
                  nmap-kube () \
                  {  nmap --open -T4 -A -v -Pn -p 80,443,2379,8080,9090,9100,9093,4001,6782-6784,6443,8443,9099,10250,10255,10256; \
                  } ;\
                  nmap-kube-discover ()\
                  {  \
                  local LOCAL_RANGE=$( ip a | awk '/eth0$/{print $2}' | sed 's,[0-9][0-9]*/.*,*,'); \
                  local SERVER_RANGES=\" \"; \
                  SERVER_RANGES+=\"10.0.0.1 \"; \
                  SERVER_RANGES+=\"10.0.1.* \"; \
                  SERVER_RANGES+=\"10.*.0-1.* \"; \
                  nmap-kube \"\${SERVER_RANGES}\" \"\${LOCAL_RANGE}\"; } ;\
                  nmap-kube-discover;" || kubectl exec -ti  $podid -n $ns -- sh -c  "apt-get update && apt-get install nmap && apt-get install iproute2;\
                  nmap-kube () \
                 {  nmap --open -T4 -A -v -Pn -p 80,443,2379,8080,9090,9100,9093,4001,6782-6784,6443,8443,9099,10250,10255,10256; \
                 } ;\
                 nmap-kube-discover ()\
                 {  \
                 local LOCAL_RANGE=$( ip a | awk '/eth0$/{print $2}' | sed 's,[0-9][0-9]*/.*,*,'); \
                 local SERVER_RANGES=\" \"; \
                 SERVER_RANGES+=\"10.0.0.1 \"; \
                 SERVER_RANGES+=\"10.0.1.* \"; \
                 SERVER_RANGES+=\"10.*.0-1.* \"; \
                 nmap-kube \"\${SERVER_RANGES}\" \"\${LOCAL_RANGE}\"; } ;\
                 nmap-kube-discover;"