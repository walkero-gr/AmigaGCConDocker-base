local buildBase(_arch='amd64', _os='os4', _gcc=11) = 
	local _name = _os + '-gcc' + _gcc + '-base-' + _arch;
	{
		"kind": 'pipeline',
		"type": 'docker',
		"name": 'build-' + _name,
		"platform": {
			"arch": _arch,
			"os": 'linux'
		},
		"steps": [
			{
				"name": 'build-base',
				"pull": 'always',
				"image": 'plugins/docker',
				"settings": {
					"repo": 'walkero/amigagccondocker',
					"tags": [
						_name + '-VERSION_TAG'
					],
					"cache_from": [
						'walkero/amigagccondocker:' + _name
					],
					"dockerfile": 'os4/exp.Dockerfile',
					"context": 'os4',
					"purge": true,
					"compress": true,
					"build_args": [
						'OS=' + _os,
						'GCC_VER=' + _gcc
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
			'awsbuilders-poweron'
		],
		"node": {
			"agents": 'awsbuilders'
		}
	};

{
	os4: {
		gcc11: {
			amd64: buildBase('amd64', 'os4', 11),
			arm64: buildBase('arm64', 'os4', 11)
		}
	}
}