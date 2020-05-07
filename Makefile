DOCKER_COMPOSE_CI = GROBID_PORT=$(GROBID_PORT) \
	docker-compose -f docker-compose.yml
DOCKER_COMPOSE = $(DOCKER_COMPOSE_CI)


SAMPLE_PDF_URL = https://cdn.elifesciences.org/articles/32671/elife-32671-v2.pdf

TEMP_DIR = ./.temp/
LOCAL_SAMPLE_PDF_PATH = $(TEMP_DIR)/sample.pdf

USER_AGENT= Dummy/user-agent

GROBID_PORT = 9070


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


ci-build-and-test:
	$(MAKE) DOCKER_COMPOSE="$(DOCKER_COMPOSE_CI)" \
		build end2end-test stop


ci-clean:
	$(DOCKER_COMPOSE_CI) down -v
