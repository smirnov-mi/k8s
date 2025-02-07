# HELM things

##  search for updates of installed charts

```bash
helm list --all-namespaces | awk -F "\t" '{ if (NR != 1) { print "Current version: "$6; system("helm search repo "$1); print "---\n\n" } }'
```

