FROM elifesciences/sciencebeam-trainer-delft-grobid_unstable:04346b26b5fa7966cef4d6ec6bba867feba52d66-cbb7e63d1b2c27c67afe591abbb23ccc95c6cfb7

ENV GROBID_MODELS_DIRECTORY=/opt/grobid/grobid-home/models

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "segmentation=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/delft-grobid-segmentation-biorxiv-no-word-embedding-2020-05-07.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "header=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/delft-grobid-header-biorxiv-no-word-embedding-2020-05-05.tar.gz" \
    --validate-pickles

RUN python -m sciencebeam_trainer_delft.sequence_labelling.tools.install_models \
    --model-base-path=${GROBID_MODELS_DIRECTORY} \
    --install "reference-segmenter=https://github.com/elifesciences/sciencebeam-models/releases/download/v0.0.1/delft-grobid-reference-segmenter-biorxiv-no-word-embedding-2020-05-07.tar.gz" \
    --validate-pickles

ENV GROBID__CRF__ENGINE=wapiti
ENV GROBID__CRF__ENGINE__SEGMENTATION=delft
ENV GROBID__CRF__ENGINE__HEADER=delft
ENV GROBID__CRF__ENGINE__REFERENCE_SEGMENTER=delft
ENV GROBID__FEATURES__REMOVE_LINE_NUMBERS=true

HEALTHCHECK --interval=10s --timeout=10s \
  CMD curl --fail http://localhost:8070 || exit 1
