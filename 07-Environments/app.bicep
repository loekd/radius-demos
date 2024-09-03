extension radius

@description('Specifies the Environment Name.')
param environmentName string = 'test'

@description('The Radius Application Name.')
param applicationName string = 'demo04'

@description('Indicates whether to use HTTPS for the Gateway.')
param useHttps string

@description('The host name of the application.')
param hostName string

resource env 'Applications.Core/environments@2023-10-01-preview' existing = {
    name: environmentName
}

