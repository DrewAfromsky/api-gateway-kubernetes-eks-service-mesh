kubectl exec $(kubectl get pod -l app=service-name -o jsonpath='{.items[0].metadata.name}') -- curl -s https://invoke-url/prod/{service}/{