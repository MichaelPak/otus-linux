FROM python:3.7-alpine

WORKDIR /app

COPY requirements.txt /app/
RUN pip install -r requirements.txt

COPY server.py /app/

EXPOSE 8080

CMD ["gunicorn", "-w 4", "server:app"]
