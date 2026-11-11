# TEMP DIAGNOSTIC PROBE (replaces xray temporarily; restored after diagnosis)
FROM nginx:alpine
COPY probe.sh /probe.sh
RUN chmod +x /probe.sh
CMD ["/probe.sh"]
