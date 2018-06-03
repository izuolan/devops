FROM squidfunk/mkdocs-material
COPY entr /bin/entr
COPY entry.sh /entry.sh
ENTRYPOINT ["sh", "/entry.sh"]
