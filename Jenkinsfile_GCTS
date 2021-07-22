@Library('piper-lib-os') _

node() {

stage('CreateRepo') {
gctsCreateRepository(
  script: this,
  host: 'https://hcluks4hana.hcldigilabs.com:8001',
  client: '200',
  abapCredentialsId: 'ABAPUserPasswordCredentialsId',
  repository: 'techED-app',
  remoteRepositoryURL: 'https://github.com/ravishankarojha/techED-app',
  role: 'Development',
  vSID: 'FEF'
  )
}
stage('CloneRepo') {
gctsCloneRepository(
  script: this,
  host: 'https://hcluks4hana.hcldigilabs.com:8001',
  client: '200',
  abapCredentialsId: 'ABAPUserPasswordCredentialsId',
  repository: 'techED-app'
)
}
stage('gctsDeploy') {
gctsDeploy(
  script: this,
  host: 'https://hcluks4hana.hcldigilabs.com:8001',
  client: '200',
  abapCredentialsId: 'ABAPUserPasswordCredentialsId',
  repository: 'techED-app'
)
}
 stage('ATC CHECK GCTS') {
     gctsExecuteABAPUnitTests(
  script: this,
  host: 'https://hcluks4hana.hcldigilabs.com:8001',
  client: '200',
  abapCredentialsId: 'ABAPUserPasswordCredentialsId',
  repository: 'techED-app'
  )
  }
}
