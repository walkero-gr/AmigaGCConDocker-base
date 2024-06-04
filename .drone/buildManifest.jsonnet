local buildManifest(_os='os4', _gcc=11) = 
	local _name = _os + '-' + 'gcc' + _gcc + '-base';
	{
		"kind": 'pipeline',
		"type": 'docker',
		"name": 'build-manifest-' + _name,
		"steps": [
			{
				"name": 'build-manifest',
				"pull": 'always',
				"image": 'plugins/manifest',
				"settings": {
					"target": 'walkero/amigagccondocker:' + _name + '-VERSION_TAG',
					"template": 'walkero/amigagccondocker:' + _name + '-ARCH' + '-VERSION_TAG',
					"platforms": [
						'linux/amd64',
						'linux/arm64'
					],
					"username": {
						"from_secret": 'DOCKERHUB_USERNAME'
					},
					"password": {
						"from_secret": 'DOCKERHUB_PASSWORD'
					},
				}
			}
		],
		"trigger": {
			"branch": {
				"include": [
					'main'
				]
			},
			"event": {
				"include": [
					'tag'
				]
			}
		},
		"depends_on": [
			'build-' + _name + '-amd64',
			'build-' + _name + '-arm64'
		]
	};

{
	os4: {
		gcc11: buildManifest('os4', 11)
	}
}