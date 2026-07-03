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
					stage('build') {
						steps {
							sh """
								cd ppc-amigaos
								docker buildx build \
									--provenance=false \
									--build-arg GCC_VER=${GCC} \
									-t ${DOCKERHUB_REPO}:os4-gcc${GCC}-base-${TAG_NAME}-${ARCH} \
									-t ${DOCKERHUB_REPO}:os4-gcc${GCC}-base-${ARCH} \
									-f Dockerfile .
							"""
						}
					}
					stage('dockerhub-login') {
						steps {
							sh """
								echo $DOCKERHUB_CREDS_PSW | docker login -u $DOCKERHUB_CREDS_USR --password-stdin
							"""
						}
					}
					stage('push-images') {
						steps {
							sh """
								set -e
								docker push ${DOCKERHUB_REPO}:os4-gcc${GCC}-base-${TAG_NAME}-${ARCH} || { echo "Failed to push tagged image"; exit 1; }
								docker push ${DOCKERHUB_REPO}:os4-gcc${GCC}-base-${ARCH} || { echo "Failed to push latest image"; exit 1; }
							"""
						}
					}
					// stage('remove-images') {
					// 	steps {
					// 		sh """
					// 			docker image ls
					// 			docker rmi -f $(docker images --filter=reference="${DOCKERHUB_REPO}:*" -q)
					// 			docker image prune -a --force
					// 			docker image ls
					// 		"""
					// 	}
					// }
				}
				post {
					always {
						sh """
							docker logout
						"""
					}
				}
			}
		}
		stage('create-manifests') {
			when { buildingTag() }
			matrix {
				axes {
					axis {
						name 'GCC'
						values '13', '11', '8', '6'
					}
				}
				stages {
					stage('create') {
						steps {
							sh """
								docker manifest create \
									--amend ${DOCKERHUB_REPO}:os4-gcc${GCC}-base-${TAG_NAME} \
									${DOCKERHUB_REPO}:os4-gcc${GCC}-base-${TAG_NAME}-amd64 \
									${DOCKERHUB_REPO}:os4-gcc${GCC}-base-${TAG_NAME}-arm64

								docker manifest create \
									--amend ${DOCKERHUB_REPO}:os4-gcc${GCC}-base \
									${DOCKERHUB_REPO}:os4-gcc${GCC}-base-amd64 \
									${DOCKERHUB_REPO}:os4-gcc${GCC}-base-arm64
							"""
						}
					}
					stage('push-manifests') {
						when { buildingTag() }
						steps {
							sh """
								echo $DOCKERHUB_CREDS_PSW | docker login -u $DOCKERHUB_CREDS_USR --password-stdin
								docker manifest push ${DOCKERHUB_REPO}:os4-gcc${GCC}-base-${TAG_NAME}
								docker manifest push ${DOCKERHUB_REPO}:os4-gcc${GCC}-base
								docker logout
							"""
						}
					}
					// stage('clear-manifests') {
					// 	when { buildingTag() }
					// 	steps {
					// 		sh """
					// 			docker manifest rm ${DOCKERHUB_REPO}:os4-gcc${GCC}-base-${TAG_NAME}
					// 			docker manifest rm ${DOCKERHUB_REPO}:os4-gcc${GCC}-base
					// 		"""
					// 	}
					// }
				}
			}
		}
	}
}
