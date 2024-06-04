local awsbuilder = import '.drone/awsbuilders.jsonnet';
local buildBase = import '.drone/buildBase.jsonnet';
local buildManifest = import '.drone/buildManifest.jsonnet';

[
	awsbuilder['poweron'],

	// GCC11 base for OS4 with clib4
	buildBase.os4.gcc11.amd64,
	buildBase.os4.gcc11.arm64,
	buildManifest.os4.gcc11
]
