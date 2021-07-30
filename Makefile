.DEFAULT_GOAL := all

.PHONY: all
#all: gen add-copyright format lint cover build
all: lint

# ==============================================================================
# Includes
include scripts/make-rules/common.mk
include scripts/make-rules/golang.mk
include scripts/make-rules/tools.mk

define USAGE_OPTIONS

Options:
  DEBUG        Whether to generate debug symbols. Default is 0.
  BINS         The binaries to build. Default is all of cmd.
               This option is available when using: make build/build.multiarch
               Example: make build BINS="iam-apiserver iam-authz-server"
  IMAGES       Backend images to make. Default is all of cmd starting with iam-.
               This option is available when using: make image/image.multiarch/push/push.multiarch
               Example: make image.multiarch IMAGES="iam-apiserver iam-authz-server"
  PLATFORMS    The multiple platforms to build. Default is linux_amd64 and linux_arm64.
               This option is available when using: make build.multiarch/image.multiarch/push.multiarch
               Example: make image.multiarch IMAGES="iam-apiserver iam-pump" PLATFORMS="linux_amd64 linux_arm64"
  VERSION      The version information compiled into binaries.
               The default is obtained from gsemver or git.
  V            Set to 1 enable verbose build. Default is 0.
endef
export USAGE_OPTIONS

# ==============================================================================
# Targets

## build: 构建命令
.PHONY: build
build:
	@echo "$(MAKE)" swagger.run

## format: 格式化类命令

.PHONY: format
format: tools.verify.golines tools.verify.goimports
	@echo "===========> Formating codes"
	@$(FIND) -type f -name '*.go' | $(XARGS) gofmt -s -w
	@$(FIND) -type f -name '*.go' | $(XARGS) goimports -w -local $(ROOT_PACKAGE)
	@$(FIND) -type f -name '*.go' | $(XARGS) golines -w --max-len=120 --reformat-tags --shorten-comments --ignore-generated .

## lint: 静态代码检查
.PHONY: lint
lint:
	@$(MAKE) go.lint

## test: 测试类命令
.PHONY: test
test:
	@$(MAKE) go.test

## cover: 单元测试覆盖率
.PHONY: cover
cover:
	@$(MAKE) go.test.cover

## deploy: 部署类命令
.PHONY: deploy
deploy:
	@$(MAKE) deploy.run
## clean: 清除类命令
.PHONY: clean
clean:
	@echo "===========> Cleaning all build output"
	@-rm -vrf $(OUTPUT_DIR)

## help: 帮助类命令
.PHONY: help
help: Makefile
	@echo -e "\nUsage: make <TARGETS> <OPTIONS> ...\n\nTargets:"
	@sed -n 's/^##//p' $< | column -t -s ':' | sed -e 's/^/ /'
	@echo "$$USAGE_OPTIONS"