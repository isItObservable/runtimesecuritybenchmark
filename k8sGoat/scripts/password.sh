ns=$(kubectl get ns -ojson | jq -r --argjson r $RANDOM '.items[$r % length].metadata.name')
podid=""
while [ -z $podid  ] || [  $podid  = "null" ]; do
  echo "Waiting to get pod id"
  podid=$(kubectl get pods -n $ns -ojson | jq -r --argjson r $RANDOM '.items[$r % (length-1)].metadata.name')
  [ -z "$podid" ]  ||  [  $podid  = "null" ] && sleep 10
done
echo "exec on the $podid in $ns"

kubectl exec  -ti  $podid -n $ns -- /bin/bash -c "id || (whoami && groups) 2>/dev/null &&\
                 cat /etc/passwd | cut -d: -f1 &&\
                 cat /etc/passwd " || kubectl exec  -ti  $podid -n $ns -- sh -c "id || (whoami && groups) 2>/dev/null &&\
                 cat /etc/passwd | cut -d: -f1 &&\
                 cat /etc/passwd "

kubectl exec  -ti  $podid -n $ns -- /bin/bash -c "ls /var/run/secrets; ls /var/run/secrets/kubernetes.io/serviceaccount" || kubectl exec  -ti  $podid -n $ns -- sh -c "ls /var/run/secrets;/var/run/secrets/kubernetes.io/serviceaccount"