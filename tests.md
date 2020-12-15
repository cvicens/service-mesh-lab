kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: preference-mutualtls
spec:
  selector:
    matchLabels:
      app: preference
  mtls:
    mode: STRICT
EOF


kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: preference-mutualtls
spec:
  selector:
    matchLabels:
      app: preference
  mtls:
    mode: PERMISSIVE
EOF




apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "preference-mutualtls"
spec:
  targets:
  - name: preference
  peers:
  - mtls:
      mode: STRICT




apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: istio-attributegen-filter
spec:
  workloadSelector:
    labels:
      app: recommendation
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: SIDECAR_INBOUND
      proxy:
        proxyVersion: '1\.8.*'
      listener:
        filterChain:
          filter:
            name: "envoy.http_connection_manager"
            subFilter:
              name: "istio.stats"
    patch:
      operation: INSERT_BEFORE
      value:
        name: istio.attributegen
        typed_config:
          "@type": type.googleapis.com/udpa.type.v1.TypedStruct
          type_url: type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
          value:
            config:
              configuration:
                "@type": type.googleapis.com/google.protobuf.StringValue
                value: |
                {
                  "attributes": [
                    {
                      "output_attribute": "istio_operationId",
                      "match": [
                        {
                          "value": "ListReviews",
                          "condition": "request.url_path == '/reviews' && request.method == 'GET'"
                        },
                        {
                          "value": "GetReview",
                          "condition": "request.url_path.matches('^/reviews/[[:alnum:]]*$') && request.method == 'GET'"
                        },
                        {
                          "value": "CreateReview",
                          "condition": "request.url_path == '/reviews/' && request.method == 'POST'"
                        }
                      ]
                    }
                  ]
                }
              vm_config:
                runtime: envoy.wasm.runtime.null
                code:
                  local: { inline_string: "envoy.wasm.attributegen" }
