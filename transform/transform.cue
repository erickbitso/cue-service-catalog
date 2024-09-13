package transform

#Application: {
	name:     string
	override: _

	$output: [
		(#Deploy & {"name": name, "override": override}).$out,
        (#Service & {"name": name, "override": override}).$out,
	]
}

#Deploy: {

	name:     string
	override: _

	$out: {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			"name": name
			labels: {
				app: name
			}
		}
		spec: {

			replicas: {
				if override.deployment.replicas != _|_ {
					override.deployment.replicas
				}
				if override.deployment.replicas == _|_ {
					1
				}
			}
			selector: {
				matchLabels: {
					app: name
				}
			}
			template: {
				metadata: {
					labels: {
						app: name
					}
				}
				spec: {
					containers: [{
						"name": name
						image:  "nginx:1.14.2"
						ports: [{
							containerPort: 80
						}]
					}]
				}
			}
		}
	}
}

#Service: {
    name: string
    override: _

    $out: {
        apiVersion: "v1"
        kind:       "Service"
        metadata: {
            "name": name
        }
        spec: {
            selector: {
                "app.kubernetes.io/name": name
            }
            ports: [{
                protocol:   "TCP"
                port:       8080
                targetPort: 80
            }]
        }
    }
}