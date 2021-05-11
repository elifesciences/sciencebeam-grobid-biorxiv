DOCKER_COMPOSE = GROBID_PORT=$(GROBID_PORT) \
	IMAGE_TAG=$(IMAGE_TAG) \
	GROBID_VARIANT_NAME=$(GROBID_VARIANT_NAME) \
	GROBID_IMAGE_TAG_SUFFIX=$(GROBID_IMAGE_TAG_SUFFIX) \
	docker-compose -f docker-compose.yml

DOCKER = docker

SAMPLE_PDF_URL = https://cdn.elifesciences.org/articles/32671/elife-32671-v2.pdf

TEMP_DIR = ./.temp/
LOCAL_SAMPLE_PDF_PATH = $(TEMP_DIR)/sample.pdf

USER_AGENT= Dummy/user-agent

GROBID_PORT = 9070

GROBID_VARIANT_NAME_DL_WAPITI = wapiti
GROBID_VARIANT_NAME_DL_NO_WORD_EMBEDDINGS = dl-no-word-embeddings
GROBID_VARIANT_NAME_DL_NO_WORD_EMBEDDINGS_WAPITI_CITATION = dl-no-word-embeddings-wapiti-citation
GROBID_VARIANT_NAME_DL_GLOVE_6B_50d = dl-glove-6B-50d

DEFAULT_GROBID_VARIANT_NAME = $(GROBID_VARIANT_NAME_DL_NO_WORD_EMBEDDINGS_WAPITI_CITATION)

GROBID_VARIANT_NAME = $(DEFAULT_GROBID_VARIANT_NAME)

IMAGE_REPO = elifesciences/sciencebeam-grobid-biorxiv
IMAGE_REPO_SUFFIX = _unstable
IMAGE_TAG = develop
GROBID_DOCKERFILE = Dockerfile.$(GROBID_VARIANT_NAME)
GROBID_IMAGE_TAG_SUFFIX = -$(GROBID_VARIANT_NAME)
GROBID_IMAGE_TAG = $(IMAGE_TAG)$(GROBID_IMAGE_TAG_SUFFIX)

NEW_IMAGE_REPO_SUFFIX =
NEW_IMAGE_TAG = $(IMAGE_TAG)
NEW_GROBID_IMAGE_TAG = $(NEW_IMAGE_TAG)$(GROBID_IMAGE_TAG_SUFFIX)


.PHONY: build
build:
	$(DOCKER_COMPOSE) build


start:
	$(DOCKER_COMPOSE) up -d


wait-for-grobid:
	docker run --rm willwill/wait-for-it \
		"localhost:$(GROBID_PORT)" \
		--timeout=10 \
		-- echo "grobid is up"


start-and-wait-for-grobid: \
	start \
	wait-for-grobid


stop:
	$(DOCKER_COMPOSE) down


status:
	$(DOCKER_COMPOSE) ps


logs:
	$(DOCKER_COMPOSE) logs -f


shell:
	$(DOCKER_COMPOSE) exec grobid bash


download-sample:
	mkdir -p "$(TEMP_DIR)"
	curl --fail --show-error --connect-timeout 60 \
		--user-agent "$(USER_AGENT)" \
		--location \
		"$(SAMPLE_PDF_URL)" \
		--silent \
		-o "$(LOCAL_SAMPLE_PDF_PATH)"


download-sample-if-not-exists:
	@if [ ! -f "$(LOCAL_SAMPLE_PDF_PATH)" ]; then \
		$(MAKE) download-sample; \
	fi


convert-sample:
	curl \
		--fail \
		--verbose \
		--form "input=@$(LOCAL_SAMPLE_PDF_PATH)" \
		localhost:$(GROBID_PORT)/api/processFulltextDocument


end2end-test: \
	download-sample-if-not-exists \
	start-and-wait-for-grobid \
	status \
	convert-sample


build-and-end2end-test-wapiti:
	$(MAKE) "GROBID_VARIANT_NAME=$(GROBID_VARIANT_NAME_DL_WAPITI)" \
		build end2end-test stop


build-and-end2end-test-dl-no-word-embeddings:
	$(MAKE) "GROBID_VARIANT_NAME=$(GROBID_VARIANT_NAME_DL_NO_WORD_EMBEDDINGS)" \
		build end2end-test stop


build-and-end2end-test-dl-no-word-embeddings-wapiti-citation:
	$(MAKE) "GROBID_VARIANT_NAME=$(GROBID_VARIANT_NAME_DL_NO_WORD_EMBEDDINGS_WAPITI_CITATION)" \
		build end2end-test stop


build-and-end2end-test-dl-glove-6b-50d:
	$(MAKE) "GROBID_VARIANT_NAME=$(GROBID_VARIANT_NAME_DL_GLOVE_6B_50d)" \
		build end2end-test stop


build-and-end2end-test-all: \
	build-and-end2end-test-wapiti \
	build-and-end2end-test-dl-no-word-embeddings \
	build-and-end2end-test-dl-no-word-embeddings-wapiti-citation \
	build-and-end2end-test-dl-glove-6b-50d


.re-tag-and-push-grobid-image:
	$(DOCKER) tag \
		$(IMAGE_REPO):$(GROBID_IMAGE_TAG) \
		$(IMAGE_REPO)$(NEW_IMAGE_REPO_SUFFIX):$(NEW_GROBID_IMAGE_TAG)
	$(DOCKER) push $(IMAGE_REPO)$(NEW_IMAGE_REPO_SUFFIX):$(NEW_GROBID_IMAGE_TAG)


.push-grobid-images:
	$(MAKE) \
		"GROBID_VARIANT_NAME=$(GROBID_VARIANT_NAME_DL_WAPITI)" \
		.re-tag-and-push-grobid-image
	$(MAKE) \
		"GROBID_VARIANT_NAME=$(GROBID_VARIANT_NAME_DL_NO_WORD_EMBEDDINGS)" \
		.re-tag-and-push-grobid-image
	$(MAKE) \
		"GROBID_VARIANT_NAME=$(GROBID_VARIANT_NAME_DL_NO_WORD_EMBEDDINGS_WAPITI_CITATION)" \
		.re-tag-and-push-grobid-image
	$(MAKE) \
		"GROBID_VARIANT_NAME=$(GROBID_VARIANT_NAME_DL_GLOVE_6B_50d)" \
		.re-tag-and-push-grobid-image
	$(MAKE) \
		"NEW_GROBID_IMAGE_TAG=latest" \
		"GROBID_VARIANT_NAME=$(DEFAULT_GROBID_VARIANT_NAME)" \
		.re-tag-and-push-grobid-image


ci-build-and-test:
	$(MAKE) build-and-end2end-test-all


ci-push-unstable-images:
	$(MAKE) "NEW_IMAGE_REPO_SUFFIX=_unstable" .push-grobid-images


ci-push-unstable-images-dryrun:
	$(MAKE) "DOCKER=echo docker" ci-push-unstable-images


ci-push-release-images:
	$(MAKE) "NEW_IMAGE_REPO_SUFFIX=" .push-grobid-images


ci-push-release-images-dryrun:
	$(MAKE) "DOCKER=echo docker" ci-push-release-images


ci-clean:
	$(DOCKER_COMPOSE) down -v
