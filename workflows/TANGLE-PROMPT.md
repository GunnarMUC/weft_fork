# Tangle-Prompt für den Klinik Beschwerdebrief-Analyzer

Kopiere diesen Prompt 1:1 in den Tangle / AI Builder im Dashboard (rechte Sidebar), nachdem du ein neues Projekt angelegt hast.

```
Baue mir einen kompletten, produktionsreifen Weft-Workflow für ein Klinikum namens "Klinik-Beschwerde-Analyzer".

Ziel: Ein Beschwerdebrief (Text) wird analysiert, Schweregrad und Inhalt bewertet, ein professioneller Antwortvorschlag erstellt und ein Human-Review durch einen Mitarbeiter eingeholt. Alles läuft 100 % lokal mit Ollama. Human-in-the-Loop muss zentral und unverzichtbar bleiben.

Technische Vorgaben (unbedingt einhalten):
- Eingabe: Ein einzelnes Text-Feld namens "Beschwerdebrief" (label: "Vollständiger Beschwerdebrief")
- Zwei separate LlmConfig-Nodes mit lokalen Ollama-Endpunkten:
  • Erste Config: Name "Mistral 7B – Analyse", endpoint "http://localhost:11434/v1", model "mistral:7b" (oder dein Tag), temperature 0.3, jsonMode: true
    System-Prompt: "Du bist ein neutraler Klinik-Qualitätsmanager. Analysiere den Beschwerdebrief streng faktenbasiert. Antworte AUSSCHLIESSLICH mit validem JSON-Objekt: {\"severity\": Zahl von 1 bis 10, \"categories\": Array von Strings, \"summary\": kurze Zusammenfassung, \"risks\": Array von Strings, \"key_points\": Array von Strings}"
  • Zweite Config: Name "Qwen – Antwortvorschlag", endpoint "http://localhost:11434/v1", model "qwen:7b" (oder dein Tag), temperature 0.7
    System-Prompt: "Du bist ein empathischer und rechtssicherer Klinik-Mitarbeiter. Erstelle einen professionellen, beruhigenden und höflichen Antwortentwurf. Schlage konkrete nächste Schritte vor."

Ablauf (genaue Reihenfolge):
1. LlmInference mit Mistral 7B → strukturierte Analyse (JSON) aus dem Beschwerdebrief
2. LlmInference mit Qwen → Antwortvorschlag unter Verwendung von Analyse + Originalbrief als Kontext
3. HumanQuery-Node mit Namen "Mitarbeiter-Review":
   - Formular-Titel: "Beschwerde-Review freigeben"
   - Felder: Textarea "Dein Feedback oder gewünschte Änderungen" (key: feedback), Checkbox "Antwort freigeben" (key: approved, default: false)
   - Im Review-Fenster: Vollständige Analyse + Antwortvorschlag anzeigen
4. Gate oder Conditional für approved-Status
5. Bei Freigabe: PostgresInsert oder Storage-Node zur Archivierung aller Daten (original, analysis, suggested_reply, feedback, approved, timestamp)
6. Abschließender Debug-Node "Finales Ergebnis & Audit" mit allen Daten

Alle Labels, Kommentare und Beschreibungen auf Deutsch. Verwende aussagekräftige Node-Namen. Der Workflow muss durable sein (Rest ate), typsicher und später einfach um E-Mail-Versand (communication/email) oder PDF erweiterbar sein. Generiere sauberen, gut kommentierten Weft-Code mit Fokus auf Auditierbarkeit und Klinik-Compliance. Human-in-the-Loop darf nicht optional sein.
```

**Vorteil von Tangle + Weft:** Du beschreibst den Workflow in natürlicher Sprache – der AI Builder generiert validen, typsicheren Code + Graphen sofort. Kein manuelles Syntax-Lernen nötig.
```

Dieser Prompt ist optimiert, um Tangle die Innovation von Weft (Compiler, HiTL, Graph) voll auszunutzen.
