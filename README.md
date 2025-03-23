# 🏥 Workplace Injury Analysis — Occupational Risk Insights from Incident Reports

## 📌 Overview

This project explores patterns in workplace injuries to support **risk mitigation, safety policy**, and **organisational awareness**. Using historical injury incident data, the analysis classifies injuries by **type, cause, and severity**, and provides clear, visual summaries using RMarkdown reporting tools.

> This project was developed using the **R tidyverse**, producing reproducible reports for decision-making across HR, safety, and operations teams.

---

## 👤 Author

**Alex Conroy**  
Individual Project  
📊 Applied Public Health / Occupational Analytics

---

## 🧾 Data Summary

- **Source:** Internal workplace injury records  
- **Format:** Single structured `.csv` file  
- **Fields:** Injury type, location, department, incident summary, outcome (time off, treatment)

> *Data has been anonymised and stripped of identifying information.*

---

## 📈 Key Outcomes

✅ Classified injury causes and types across departments  
✅ Identified top risk zones and event triggers  
✅ Highlighted trends over time and repeat patterns  
✅ Delivered dual-report format: deep dive + high-level SOAP summary

---

## 🛠️ Technology Used

- **Language:** R  
- **Libraries:** `tidyverse`, `lubridate`, `ggplot2`  
- **Tools:** RMarkdown for reproducible reporting

---

## 📂 Project Structure

workplace-injury-analysis/ ├── data/ │ └── injuries.csv # Anonymised input data ├── notebooks/ │ ├── Injury_Analysis_2020.Rmd # Main analysis notebook │ └── Injury_SOAP_2020.Rmd # Summary-style (SOAP format) notebook ├── report/ │ ├── Injury_Analysis_2020.html # Full rendered report │ └── Injury_SOAP_2020.html # Condensed, stakeholder-ready version ├── src/ │ └── injury_analysis.R # Placeholder for refactored R functions ├── requirements.txt # R packages used └── README.md # This file
---

## 📋 Reporting Outputs

- **`Injury_Analysis_2020.html`** — Deep dive into incident patterns, department breakdowns, and injury categories  
- **`Injury_SOAP_2020.html`** — Executive-style summary using SOAP (Subjective, Objective, Assessment, Plan)

---

## 🔮 Future Work

- Incorporate **cost impact** of injuries by outcome  
- Add **predictive modeling** for likelihood of recurrence  
- Create a **Shiny dashboard** for live reporting and filtering

---

## 📄 License

The data used in this project is private and anonymised. No personal identifiers are included.

---

## 💼 Why This Project?

This project demonstrates:
- ✅ Clear communication of health & safety data  
- ✅ Reproducible analysis using RMarkdown  
- ✅ Business-aligned insights to support real operational decisions

It’s a great example of stakeholder-ready data science in practice.

