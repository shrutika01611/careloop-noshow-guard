# CareLoop Clinics — No-Show Guard

**GitHub Repository:** https://github.com/shrutika01611/careloop-noshow-guard

## Summary
1. **Part 1 (Data Cleaning & Enrichment):** Cleaned `appointments.csv` from **1,020** raw rows down to **990** valid rows (**218** no-shows overall, **22.0%** no-show rate) and enriched all **8** outpatient clinics with live weather temperatures.
2. **Part 2 (Exploratory & SQL Analysis):** Across the **8** clinics, no-show rates ranged from **13.8%** (Vaishali Nagar Clinic, Jaipur) up to **33.3%** (Gomti Nagar Care Point, Lucknow).
3. **Part 3 (Predictive Modeling):** Selected a `StandardScaler + LogisticRegression` pipeline (`cv_auc` = **0.7737**, test ROC-AUC = **0.7889**) using a **0.35** risk threshold instead of **0.50**.
4. **Part 4 (GenAI Follow-Up Notes & Validation):** Validated structured call-centre note extraction (`FollowupInsight` Pydantic schema + allowed `root_cause` list), skipped blank notes cleanly, and used a CRAFT prompt with explicit allowed labels and an `other` fallback.

## Recommendation
To reduce missed outpatient slots at CareLoop Clinics—where **218** of **990** cleaned bookings (**22.0%**) resulted in no-shows and clinic no-show rates reach **33.3%** in Lucknow (Gomti Nagar Care Point) and **27.3%** in Pune (Hadapsar Care Centre)—CareLoop should deploy the evening-before `LogisticRegression` risk scorer at a **0.35** probability threshold (achieving **0.79** test ROC-AUC and **0.57** test recall, flagging **49** of **198** test appointments) and prioritize outreach for high-risk bookings with long `lead_days` (mean **11.82** days; **29.9%** of bookings over **14** days), prior no-shows, or unconfirmed reminders. Pairing evening calls with structured call-centre `root_cause` tracking (such as `forgot_or_no_reminder` vs. rescheduling/travel issues) lets staff target reminder timing and slot backfill where missed visits are highest while keeping call volume manageable.

## Model Choice & Threshold
We chose the `StandardScaler + LogisticRegression` pipeline over the unconstrained decision tree (which overfit with **1.00** train accuracy vs. **0.67** test accuracy), depth-3 tree (**0.6784** 5-fold CV ROC-AUC), and untuned/tuned random forests (**0.7466** and **0.7669** 5-fold CV ROC-AUC), because it achieved the highest 5-fold cross-validated training ROC-AUC (**0.7737**) and test ROC-AUC (**0.7889**, rounded to **0.79**). We chose threshold **0.35** over **0.50** because on out-of-fold training predictions it raised F1 from **0.3471** to **0.4892** and recall from **0.2485** to **0.4675** (reaching **0.57** recall and **0.57** precision on the test set with **49** flagged appointments), aligning with clinic operations where missing a no-show wastes a doctor slot while an extra call takes only a minute.

## Limitations
- **The 10 notes are an illustration and cannot show the real reasons clinic-wide:** Analyzing only the first **10** follow-up notes (including blank/skipped rows) provides a small sample and cannot represent root-cause proportions across all missed visits.
- **The cleaning statistics came from all rows before the split:** Imputing missing `age` and `distance_km` with medians and computing IQR outlier fences before splitting can introduce minor preprocessing leakage.
- **The data are observational, so associations are not causes:** Features such as `reminder_sent` and `lead_days` show statistical associations with no-shows in historical records rather than causal proof from a randomized intervention.
