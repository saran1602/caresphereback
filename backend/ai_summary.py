from datetime import datetime

# Optional LLM Support
try:
    from openai import OpenAI
    client = OpenAI()
    LLM_AVAILABLE = True
except:
    LLM_AVAILABLE = False


# ================= ALLERGY CHECK =================

def check_allergy_conflicts(allergies, prescriptions):

    alerts = []

    allergy_drug_map = {
        "Penicillin": ["Amoxicillin", "Ampicillin"],
        "Aspirin": ["Ibuprofen"],
        "Sulfa": ["Sulfamethoxazole"]
    }

    for allergy in allergies:

        if allergy in allergy_drug_map:

            risky_meds = allergy_drug_map[allergy]

            for med in prescriptions:

                if med["medicine"] in risky_meds:

                    alerts.append(
                        f"⚠ Patient allergic to {allergy}. Avoid {med['medicine']}."
                    )

    return alerts


# ================= RULE BASED SUMMARY =================

def rule_based_summary(patient, allergies, symptoms, vitals, prescriptions):

    summary = []

    summary.append("PATIENT QUICK SUMMARY\n")

    summary.append(f"Name: {patient['name']}")
    summary.append(f"Age: {patient['age']}")
    summary.append(f"Conditions: {patient['conditions']}")

    if allergies:
        summary.append(f"\n⚠ Allergies: {', '.join(allergies)}")

    if symptoms:
        summary.append("\nRecent Symptoms:")
        for s in symptoms[-3:]:
            summary.append(f"- {s['symptom']}")

    if vitals:
        v = vitals[-1]
        summary.append("\nLatest Vitals:")
        summary.append(f"BP: {v['bp']} | Sugar: {v['sugar']}")

    if prescriptions:
        summary.append("\nCurrent Medications:")
        for p in prescriptions:
            summary.append(f"- {p['medicine']} {p['dosage']}")

    return "\n".join(summary)


# ================= AI SUMMARY =================

def generate_ai_summary(patient, allergies, symptoms, vitals, prescriptions, scans):

    allergy_alerts = check_allergy_conflicts(allergies, prescriptions)

    try:

        from openai import OpenAI
        client = OpenAI()

        formatted = f"""
Patient Name: {patient['name']}
Age: {patient['age']}
Conditions: {patient['conditions']}

Allergies: {allergies}
Symptoms: {symptoms}
Vitals: {vitals}
Medicines: {prescriptions}
Scans: {scans}
"""

        prompt = f"""
You are a clinical assistant.

Generate short medical risk summary highlighting:
- abnormal vitals
- disease risk
- medication issues
- allergy alerts
"""

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are a medical assistant."},
                {"role": "user", "content": formatted + prompt}
            ],
            temperature=0.2
        )

        summary = response.choices[0].message.content

    except Exception as e:

        print("⚠ AI Summary failed → Using Rule Based Summary")

        summary = rule_based_summary(
            patient,
            allergies,
            symptoms,
            vitals,
            prescriptions
        )

    return {
        "summary": summary,
        "allergy_alerts": allergy_alerts
    }