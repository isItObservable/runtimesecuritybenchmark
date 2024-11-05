 ns=$(kubectl get ns -ojson | jq -r --argjson r $RANDOM '.items[$r % length].metadata.name')
 podid=""
while [ -z $podid  ] || [  $podid  = "null" ]; do
  echo "Waiting to get pod id"
  podid=$(kubectl get pods -n $ns -ojson | jq -r --argjson r $RANDOM '.items[$r % (length-1)].metadata.name')
  [ -z "$podid" ]  ||  [  $podid  = "null" ] && sleep 10
done
echo "exec on the $podid in $ns"
 kubectl exec -ti $podid -n $ns -- /bin/bash -c "apt-get install -y stress-ng &&\
            stress-ng --vm 1 --vm-bytes 1G --verify -t 5m" ||  kubectl exec -ti $podid -n $ns -- sh -c "apt-get install -y stress-ng &&\
            stress-ng --vm 1 --vm-bytes 1G --verify -t 5m"
