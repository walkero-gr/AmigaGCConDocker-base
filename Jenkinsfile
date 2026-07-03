pipeline {
	agent any
	environment {
		DOCKERHUB_CREDS=credentials('walkero-dockerhub')
		DOCKERHUB_REPO="walkero/amigagccondocker"
	}
	stages {
		stage('build-dependencies-image') {
			when { buildingTag() }
			matrix {
				axes {
					axis {
						name 'ARCH'
						values 'amd64', 'arm64'
					}
				}
				agent { label "agent-${ARCH}" }
				stages {
					stage('build') {
						steps {
							sh """
								cd ppc-amigaos
								docker buildx build \
									--no-cache \
									--provenance=false \
									-t ${DOCKERHUB_REPO}:deps \
									-f Dockerfile.deps .
							"""
						}
					}
				}
			}
		}

		stage('build-images') {
			when { buildingTag() }
			matrix {
				axes {
					axis {
						name 'ARCH'
						values 'amd64', 'arm64'
					}
					axis {
						name 'GCC'
						values '13', '11', '8', '6'
					}
				}
				agent { label "agent-${ARCH}" }
				stages {
					stage('build-and-push') {
						steps {
							script {
								buildAndPush(GCC, ARCH)
							}
						}
					}
				}
			}
		}
		stage('create-manifests') {
			when { buildingTag() }
			stages {
				stage('create-and-push') {
					steps {
						script {
							createAndPushManifests(['13', '11', '8', '6'])
						}
					}
				}
			}
		}
	}
}

def buildAndPush(gccVer, arch) {
	def imageTagBase = "${env.DOCKERHUB_REPO}:os4-gcc${gccVer}-base"
	def imageTagVersioned = "${imageTagBase}-${env.TAG_NAME}-${arch}"
	def imageTagLatest = "${imageTagBase}-${arch}"

	try {
		sh """
			cd ppc-amigaos
			docker buildx build \
				--provenance=false \
				--build-arg GCC_VER=${gccVer} \
				-t ${imageTagVersioned} \
				-t ${imageTagLatest} \
				-f Dockerfile .
		"""
		retry(3) {
			sh """
				echo \$DOCKERHUB_CREDS_PSW | docker login -u \$DOCKERHUB_CREDS_USR --password-stdin
				docker push ${imageTagVersioned}
				docker push ${imageTagLatest}
			"""
		}
	} finally {
		sh 'docker logout'
	}
}

def createAndPushManifests(gccVersions) {
	gccVersions.each { gccVer ->
		def imageTagBase = "${env.DOCKERHUB_REPO}:os4-gcc${gccVer}-base"
		def imageTagVersioned = "${imageTagBase}-${env.TAG_NAME}"
		def imageTagLatest = imageTagBase

		sh """
			docker manifest create \
				--amend ${imageTagVersioned} \
				${imageTagVersioned}-amd64 \
				${imageTagVersioned}-arm64

			docker manifest create \
				--amend ${imageTagLatest} \
				${imageTagLatest}-amd64 \
				${imageTagLatest}-arm64
		"""
	}

	try {
		sh 'echo \$DOCKERHUB_CREDS_PSW | docker login -u \$DOCKERHUB_CREDS_USR --password-stdin'
		gccVersions.each { gccVer ->
			def imageTagBase = "${env.DOCKERHUB_REPO}:os4-gcc${gccVer}-base"
			def imageTagVersioned = "${imageTagBase}-${env.TAG_NAME}"
			def imageTagLatest = imageTagBase

			retry(3) {
				sh """
					docker manifest push ${imageTagVersioned}
					docker manifest push ${imageTagLatest}
				"""
			}
		}
	} finally {
		sh 'docker logout'
	}
}