FROM python:3.9-slim

WORKDIR /app

RUN apt-get update \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip3 install -r requirements.txt

COPY .streamlit/config.toml .streamlit/
COPY app.py .

RUN groupadd -g 1005 appgroup && \
    useradd -u 1005 -g appgroup appuser && \
    chown -R appuser:appgroup /app

EXPOSE 80

USER appuser

ENTRYPOINT ["streamlit", "run"]
CMD ["app.py"]