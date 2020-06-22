def name = 'ink'
def app
def version

node {
  checkout scm
  stage('Build') {
    app = docker.build("eu.gcr.io/ivx-docker-registry/${name}", "--pull .")
  }

  stage('Test') {
    app.run()
  }
}

if (env.BRANCH_NAME == 'master') {
  timeout (time: 8, unit: 'HOURS') {
    stage 'Deploy'
    input 'Deploy as release?'
    node {
      app.inside("-u 0:0") {
        version = sh (
          returnStdout: true,
          script: "mix version"
        ).trim()
      }
      node {
        sh "github-release-wrapper release --user ivx --repo ${name} --tag v${version} --name v${version}"
      }
    }
  }
}
