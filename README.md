# ScienceBeam GROBID bioRxiv

A variation of the [GROBID](https://github.com/kermitt2/grobid) image, that includes models trained on bioRxiv. It builds on top of changes in the following [GROBID fork](https://github.com/elifesciences/grobid) and [sciencebeam-trainer-delft](https://github.com/elifesciences/sciencebeam-trainer-delft) for the DL models.

## Run Image

```bash
docker pull elifesciences/sciencebeam-grobid-biorxiv
docker run -t --rm --init -p 8080:8070 -p 8081:8071 \
  elifesciences/sciencebeam-grobid-biorxiv
```

(for deployments it is recommended to use a specific tag)

See also [GROBID and containers](https://grobid.readthedocs.io/en/latest/Grobid-docker/)
