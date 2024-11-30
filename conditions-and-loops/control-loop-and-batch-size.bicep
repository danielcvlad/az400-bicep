//starting from a value of 1, 3 times.
//batchsize = number of objects to be deployed at a time.


@batchSize(2)
resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = [for i in range(1,3): {
  name: 'app${i}'
  // ...
}]
