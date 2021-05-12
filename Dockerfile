FROM elifesciences/sciencebeam-trainer-delft-grobid:0.0.27 AS base

ENV GROBID_MODELS_DIRECTORY=/opt/grobid/grobid-home/models
ENV GROBID__CRF__ENGINE=wapiti
ENV GROBID__HEADER__USE_HEURISTICS=false
ENV GROBID__FEATURES__REMOVE_LINE_NUMBERS=false
ENV GROBID__3RDPARTY__PDF2XML__MEMORY__TIMEOUT__SEC=300
ENV GROBID__PDF__BLOCKS__MAX=1000000
ENV GROBID__PDF__TOKENS__MAX=10000000

HEALTHCHECK --interval=10s --timeout=10s \
  CMD curl --fail http://localhost:8070 || exit 1


FROM base AS wapiti

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "segmentation=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/wapiti-grobid-segmentation-biorxiv-2020-06-01.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "header=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/wapiti-grobid-header-biorxiv-2020-06-01.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "reference-segmenter=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/wapiti-grobid-reference-segmenter-biorxiv-2020-06-01.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "citation=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/2020-10-04-wapiti-grobid-citation-biorxiv.tar.gz" \
    --validate-pickles


FROM base AS dl-no-word-embeddings

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "segmentation=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/2020-10-04-delft-grobid-segmentation-biorxiv-no-word-embedding-text-feature.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "header=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/2020-10-04-delft-grobid-header-biorxiv-no-word-embedding.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "affiliation-address=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/2020-10-04-delft-grobid-affiliation-address-biorxiv-no-word-embedding.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "reference-segmenter=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/2020-10-04-delft-grobid-reference-segmenter-biorxiv-no-word-embedding.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "citation=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/2020-10-04-delft-grobid-citation-biorxiv-no-word-embedding.tar.gz" \
    --validate-pickles

ENV GROBID__CRF__ENGINE__SEGMENTATION=delft
ENV GROBID__CRF__ENGINE__HEADER=delft
ENV GROBID__CRF__ENGINE__AFFILIATION_ADDRESS=delft
ENV GROBID__CRF__ENGINE__REFERENCE_SEGMENTER=delft
ENV GROBID__CRF__ENGINE__CITATION=delft

ENV GROBID__FEATURES__SEGMENTATION_WHOLE_LINE_FEATURE=true

ENV SCIENCEBEAM_DELFT_MAX_SEQUENCE_LENGTH=2000
ENV SCIENCEBEAM_DELFT_INPUT_WINDOW_STRIDE=1800
ENV SCIENCEBEAM_DELFT_BATCH_SIZE=1
ENV SCIENCEBEAM_DELFT_STATEFUL=false


FROM dl-no-word-embeddings AS dl-no-word-embeddings-wapiti-citation

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "citation=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/2020-10-04-wapiti-grobid-citation-biorxiv.tar.gz" \
    --validate-pickles

ENV GROBID__CRF__ENGINE__CITATION=wapiti


FROM dl-no-word-embeddings AS dl-glove-6B-50d

ENV EMBEDDING_REGISTRY_PATH="${PROJECT_FOLDER}/embedding-registry.json"

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "segmentation=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/delft-grobid-segmentation-biorxiv-glove-6b-50d-2020-05-22.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "header=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/delft-grobid-header-biorxiv-glove-6b-50d-2020-05-22.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "reference-segmenter=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/delft-grobid-reference-segmenter-biorxiv-glove-6b-50d-2020-05-22.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.embedding \
    override-embedding-url \
    --registry-path="${EMBEDDING_REGISTRY_PATH}" \
    --override-url="glove.6B.50d=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/glove.6B.50d.mdb.xz"

RUN python -m sciencebeam_trainer_delft.embedding \
    preload \
    --registry-path="${EMBEDDING_REGISTRY_PATH}" \
    --embedding="glove.6B.50d"

ENV GROBID__CRF__ENGINE__SEGMENTATION=delft
ENV GROBID__CRF__ENGINE__HEADER=delft
ENV GROBID__CRF__ENGINE__REFERENCE_SEGMENTER=delft
