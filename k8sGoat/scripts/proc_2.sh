 ns=$(kubectl get ns -ojson | jq -r --argjson r $RANDOM '.items[$r % length].metadata.name')
 podid=""
while [ -z $podid  ] || [  $podid  = "null" ]; do
  echo "Waiting to get pod id"
  podid=$(kubectl get pods -n $ns -ojson | jq -r --argjson r $RANDOM '.items[$r % (length-1)].metadata.name')
  [ -z "$podid" ]  ||  [  $podid  = "null" ] && sleep 10
done
echo "exec on the $podid in $ns"
kubectl exec -ti $podid -n $ns -- /bin/bash -c "(cat /proc/version || uname -a ) 2>/dev/null ;\
                lsb_release -a 2>/dev/null; \
                cat /etc/os-release 2>/dev/null ;\
                (env || set) 2>/dev/null "||  kubectl exec -ti  $podid -n $ns -- sh -c "(cat /proc/version || uname -a ) 2>/dev/null ;\
                lsb_release -a 2>/dev/null ; \
                cat /etc/os-release 2>/dev/null ;\
                (env || set) 2>/dev/null "