#!/bin/bash

CHKSCRIPTURL="https://raw.githubusercontent.com/agentur2c/checkmk-froxlor/refs/heads/main/froxlor_version"
CHKSCRIPT="froxlor_version"

INSTPATH="/usr/lib/check_mk_agent/local"

# Alte Installationen aus verschachtelten Intervall-Ordnern (z. B. /10800/) löschen
rm -f $INSTPATH/*/$CHKSCRIPT

# Verzeichnis anlegen (falls nicht existent)
mkdir -p $INSTPATH

# Prüfen, ob wget oder curl vorhanden ist und Download ausführen
if command -v wget >/dev/null 2>&1; then
    wget -q -O $INSTPATH/$CHKSCRIPT "$CHKSCRIPTURL"
elif command -v curl >/dev/null 2>&1; then
    curl -s -o $INSTPATH/$CHKSCRIPT "$CHKSCRIPTURL"
else
    echo "Fehler: Weder 'wget' noch 'curl' wurden auf diesem System gefunden." >&2
    echo "Bitte installiere eines der beiden Tools und starte die Installation erneut." >&2
    exit 1
fi

# Ausführbar machen
chmod +x $INSTPATH/$CHKSCRIPT

echo "Installation erfolgreich abgeschlossen!"
echo "Bitte nutze Setup -> Service Discovery in Checkmk für diesen Host, um den Service zu aktivieren."

