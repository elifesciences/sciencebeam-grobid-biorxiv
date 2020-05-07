FROM elifesciences/sciencebeam-trainer-delft-grobid_unstable:04346b26b5fa7966cef4d6ec6bba867feba52d66-c629788be4bf7a2273b1b1e84d7cc5b51303a674

ENV GROBID__CRF__ENGINE=wapiti
ENV GROBID__FEATURES__REMOVE_LINE_NUMBERS=true

HEALTHCHECK --interval=10s --timeout=10s \
  CMD curl --fail http://localhost:8070 || exit 1
