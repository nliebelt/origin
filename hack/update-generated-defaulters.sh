#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE}")/lib/init.sh"

SCRIPT_ROOT=$(dirname ${BASH_SOURCE})/..
CODEGEN_PKG=${CODEGEN_PKG:-$(cd ${SCRIPT_ROOT}; ls -d -1 ./vendor/k8s.io/code-generator 2>/dev/null || echo ../../../k8s.io/code-generator)}

go install ./${CODEGEN_PKG}/cmd/defaulter-gen

function codegen::join() { local IFS="$1"; shift; echo "$*"; }

# enumerate group versions
ALL_FQ_APIS=(
    github.com/openshift/origin/staging/src/github.com/openshift/template-service-broker/apis/config/v1
    github.com/openshift/origin/pkg/apps/apis/apps/v1
    github.com/openshift/origin/pkg/authorization/apis/authorization/v1
    github.com/openshift/origin/pkg/build/apis/build/v1
    github.com/openshift/origin/pkg/cmd/server/apis/config/v1
    github.com/openshift/origin/pkg/image/apis/image/v1
    github.com/openshift/origin/pkg/oauth/apis/oauth/v1
    github.com/openshift/origin/pkg/project/apis/project/v1
    github.com/openshift/origin/pkg/quota/apis/quota/v1
    github.com/openshift/origin/pkg/route/apis/route/v1
    github.com/openshift/origin/pkg/security/apis/security/v1
    github.com/openshift/origin/pkg/template/apis/template/v1
    github.com/openshift/origin/pkg/user/apis/user/v1
)

ALL_PEERS=(
    k8s.io/apimachinery/pkg/api/resource
    k8s.io/apimachinery/pkg/apis/meta/v1
    k8s.io/apimachinery/pkg/apis/meta/internalversion
    k8s.io/apimachinery/pkg/runtime
    k8s.io/apimachinery/pkg/conversion
    k8s.io/apimachinery/pkg/types
    k8s.io/api/core/v1
    k8s.io/kubernetes/pkg/apis/core
    k8s.io/kubernetes/pkg/apis/core/v1
)


echo "Generating defaults"
${GOPATH}/bin/defaulter-gen   --input-dirs $(codegen::join , "${ALL_FQ_APIS[@]}") --extra-peer-dirs $(codegen::join , "${ALL_PEERS[@]}") --build-tag=ignore_autogenerated_openshift -O zz_generated.defaults --go-header-file ${SCRIPT_ROOT}/hack/boilerplate.txt --v=8 "$@"
