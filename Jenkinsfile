pipeline {
	agent any
	environment {
		DOCKERHUB_CREDS=credentials('walkero-dockerhub')
		DOCKERHUB_REPO="walkero/amigagccondocker"
	}
	stages {
		stage('ppc-amigaos') {
			when {
				allOf {
					buildingTag()
					tag pattern: "os4-.*", comparator: "REGEXP"
				}
			}
			environment {
				TAG_VERSION = "${TAG_NAME.replace('os4-', '')}"
			}
			stages {
				stage('build-dependencies-image') {
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
											-t ${DOCKERHUB_REPO}:ppc-amigaos-deps \
											-f Dockerfile.deps .
									"""
								}
							}
						}
					}
				}
				stage('build-images') {
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
										buildAndPush_os4(GCC, ARCH)
									}
								}
							}
						}
					}
				}
				stage('create-manifests') {
					stages {
						stage('create-and-push') {
							steps {
								script {
									createAndPushManifests('os4',['13', '11', '8', '6'])
								}
							}
						}
					}
				}
			}
		}
		stage('m68k-amigaos') {
			when {
				allOf {
					buildingTag()
					tag pattern: "m68k-.*", comparator: "REGEXP"
				}
			}
			environment {
				TAG_VERSION = "${TAG_NAME.replace('m68k-', '')}"
			}
			stages {
				stage('build-dependencies-image') {
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
										cd m68k-amigaos
										docker buildx build \
											--no-cache \
											--provenance=false \
											-t ${DOCKERHUB_REPO}:m68k-amigaos-deps \
											-f Dockerfile.deps .
									"""
								}
							}
						}
					}
				}
				stage('build-images') {
					matrix {
						axes {
							axis {
								name 'ARCH'
								values 'amd64', 'arm64'
							}
							axis {
								name 'GCC'
								values '6'
							}
						}
						agent { label "agent-${ARCH}" }
						stages {
							stage('build-and-push') {
								steps {
									script {
										buildAndPush_os4(GCC, ARCH)
									}
								}
							}
						}
					}
				}
				stage('create-manifests') {
					stages {
						stage('create-and-push') {
							steps {
								script {
									createAndPushManifests('m68k', ['6'])
								}
							}
						}
					}
				}
			}
		}
	}
}

def buildAndPush_os4(gccVer, arch) {
	def imageTagBase = "${env.DOCKERHUB_REPO}:os4-gcc${gccVer}-base"
	def imageTagVersioned = "${imageTagBase}-${env.TAG_NAME}-${arch}"
	def imageTagLatest = "${imageTagBase}-${arch}"

	try {
		sh """
			echo imageTagBase: ${imageTagBase}
			echo imageTagVersioned: ${imageTagVersioned}
			echo imageTagLatest: ${imageTagLatest}
		"""
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

def createAndPushManifests(system, gccVersions) {
	gccVersions.each { gccVer ->
		def imageTagBase = "${env.DOCKERHUB_REPO}:${system}-gcc${gccVer}-base"
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
			def imageTagBase = "${env.DOCKERHUB_REPO}:${system}-gcc${gccVer}-base"
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

def buildAndPush_m68k(gccVer, arch) {
	def imageTagBase = "${env.DOCKERHUB_REPO}:m68k-gcc${gccVer}-base"
	def imageTagVersioned = "${imageTagBase}-${env.TAG_NAME}-${arch}"
	def imageTagLatest = "${imageTagBase}-${arch}"

	try {
		sh """
			echo imageTagBase: ${imageTagBase}
			echo imageTagVersioned: ${imageTagVersioned}
			echo imageTagLatest: ${imageTagLatest}
		"""
		// sh """
		// 	cd m68k-amigaos
		// 	docker buildx build \
		// 		--provenance=false \
		// 		--build-arg GCC_VER=${gccVer} \
		// 		-t ${imageTagVersioned} \
		// 		-t ${imageTagLatest} \
		// 		-f Dockerfile .
		// """
		// retry(3) {
		// 	sh """
		// 		echo \$DOCKERHUB_CREDS_PSW | docker login -u \$DOCKERHUB_CREDS_USR --password-stdin
		// 		docker push ${imageTagVersioned}
		// 		docker push ${imageTagLatest}
		// 	"""
		// }
	} finally {
		sh 'docker logout'
	}
}