# ScienceBeam GROBID bioRxiv

A variation of the [GROBID](https://github.com/kermitt2/grobid) image, that includes models trained on bioRxiv. It builds on top of changes in the following [GROBID fork](https://github.com/elifesciences/grobid) and [sciencebeam-trainer-delft](https://github.com/elifesciences/sciencebeam-trainer-delft) for the DL models.

## Run Image

There are multiple [image tags of elifesciences/sciencebeam-grobid-biorxiv](https://hub.docker.com/r/elifesciences/sciencebeam-grobid-biorxiv/tags), with the following tag suffixes:

| tag suffix | description |
| ---------- | ----------- |
| `wapiti`   | traditional, non-DL model |
| `dl-no-word-embeddings` | DL model, not using any word embeddings |
| `dl-glove-6B-50d` | DL model, using [glove.6B 50d word embeddings](https://nlp.stanford.edu/projects/glove/). This improves the accuracy over not using any word embeddings while still keeping the image size reasonable. (recommended) |

All of the models are trained using the same bioRxiv dataset.

The `latest` tag will be set to the latest `dl-glove-6B-50d` image.

```bash
docker pull elifesciences/sciencebeam-grobid-biorxiv
docker run -t --rm --init -p 8080:8070 -p 8081:8071 \
  elifesciences/sciencebeam-grobid-biorxiv
```

(for deployments it is recommended to use a specific tag)

See also [GROBID and containers](https://grobid.readthedocs.io/en/latest/Grobid-docker/)
