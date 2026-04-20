/* =========================================================
   Healthcare Claims & Cost Analysis - queries.sql (Oracle)
   ========================================================= */

/* 1) Total claims count */
SELECT COUNT(*) AS total_claims
FROM claims;

/* 2) Total claim amount */
SELECT ROUND(SUM(claim_amount), 2) AS total_claim_amount
FROM claims;

/* 3) Total patients by state */
SELECT state, COUNT(*) AS total_patients
FROM patients
GROUP BY state
ORDER BY total_patients DESC, state;

/* 4) Total providers by specialty */
SELECT specialty, COUNT(*) AS total_providers
FROM providers
GROUP BY specialty
ORDER BY total_providers DESC, specialty;

/* 5) Top 10 highest cost patients */
SELECT
    c.patient_id,
    p.patient_name,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_cost
FROM claims c
JOIN patients p
    ON c.patient_id = p.patient_id
GROUP BY c.patient_id, p.patient_name
ORDER BY total_claim_cost DESC, c.patient_id
FETCH FIRST 10 ROWS ONLY;

/* 6) Average claim amount by status */
SELECT
    status,
    ROUND(AVG(claim_amount), 2) AS avg_claim_amount
FROM claims
GROUP BY status
ORDER BY avg_claim_amount DESC;

/* 7) Monthly claim trend */
SELECT
    TO_CHAR(claim_date, 'YYYY-MM') AS claim_month,
    COUNT(*) AS total_claims,
    ROUND(SUM(claim_amount), 2) AS total_claim_amount
FROM claims
GROUP BY TO_CHAR(claim_date, 'YYYY-MM')
ORDER BY claim_month;

/* 8) Approved vs Denied vs Pending claim distribution */
SELECT
    status,
    COUNT(*) AS claim_count,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM claims
GROUP BY status
ORDER BY claim_count DESC;

/* 9) Providers with highest total claim amount */
SELECT
    c.provider_id,
    p.provider_name,
    p.specialty,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_amount
FROM claims c
JOIN providers p
    ON c.provider_id = p.provider_id
GROUP BY c.provider_id, p.provider_name, p.specialty
ORDER BY total_claim_amount DESC, c.provider_id
FETCH FIRST 10 ROWS ONLY;

/* 10) Average claim amount per patient */
SELECT
    c.patient_id,
    p.patient_name,
    ROUND(AVG(c.claim_amount), 2) AS avg_claim_amount
FROM claims c
JOIN patients p
    ON c.patient_id = p.patient_id
GROUP BY c.patient_id, p.patient_name
ORDER BY avg_claim_amount DESC, c.patient_id;

/* 11) Outstanding unpaid or partially paid claims */
SELECT
    c.claim_id,
    c.patient_id,
    c.provider_id,
    c.claim_amount,
    NVL(SUM(py.paid_amount), 0) AS total_paid_amount,
    ROUND(c.claim_amount - NVL(SUM(py.paid_amount), 0), 2) AS outstanding_amount,
    c.status
FROM claims c
LEFT JOIN payments py
    ON c.claim_id = py.claim_id
GROUP BY
    c.claim_id,
    c.patient_id,
    c.provider_id,
    c.claim_amount,
    c.status
HAVING c.claim_amount - NVL(SUM(py.paid_amount), 0) > 0
ORDER BY outstanding_amount DESC, c.claim_id;

/* 12) Payment vs claim variance */
SELECT
    c.claim_id,
    c.claim_amount,
    NVL(SUM(py.paid_amount), 0) AS total_paid_amount,
    ROUND(c.claim_amount - NVL(SUM(py.paid_amount), 0), 2) AS variance
FROM claims c
LEFT JOIN payments py
    ON c.claim_id = py.claim_id
GROUP BY c.claim_id, c.claim_amount
ORDER BY variance DESC, c.claim_id;

/* 13) State-wise healthcare cost */
SELECT
    pt.state,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_cost
FROM claims c
JOIN patients pt
    ON c.patient_id = pt.patient_id
GROUP BY pt.state
ORDER BY total_claim_cost DESC, pt.state;

/* 14) Top specialties by total claim amount */
SELECT
    p.specialty,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_cost
FROM claims c
JOIN providers p
    ON c.provider_id = p.provider_id
GROUP BY p.specialty
ORDER BY total_claim_cost DESC, p.specialty;

/* 15) Patients with repeated claims (5 or more claims) */
SELECT
    c.patient_id,
    p.patient_name,
    COUNT(*) AS total_claims
FROM claims c
JOIN patients p
    ON c.patient_id = p.patient_id
GROUP BY c.patient_id, p.patient_name
HAVING COUNT(*) >= 5
ORDER BY total_claims DESC, c.patient_id;

/* 16) Top 3 claims by amount within each state */
SELECT
    state,
    claim_id,
    patient_id,
    claim_amount,
    rn
FROM (
    SELECT
        pt.state,
        c.claim_id,
        c.patient_id,
        c.claim_amount,
        ROW_NUMBER() OVER (
            PARTITION BY pt.state
            ORDER BY c.claim_amount DESC, c.claim_id
        ) AS rn
    FROM claims c
    JOIN patients pt
        ON c.patient_id = pt.patient_id
)
WHERE rn <= 3
ORDER BY state, rn;

/* 17) Rank providers by claim amount */
SELECT
    c.provider_id,
    p.provider_name,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_amount,
    DENSE_RANK() OVER (
        ORDER BY SUM(c.claim_amount) DESC
    ) AS provider_rank
FROM claims c
JOIN providers p
    ON c.provider_id = p.provider_id
GROUP BY c.provider_id, p.provider_name
ORDER BY provider_rank, c.provider_id;

/* 18) Running monthly claim total */
SELECT
    claim_month,
    monthly_claim_amount,
    SUM(monthly_claim_amount) OVER (
        ORDER BY claim_month
    ) AS running_total_claim_amount
FROM (
    SELECT
        TO_CHAR(claim_date, 'YYYY-MM') AS claim_month,
        ROUND(SUM(claim_amount), 2) AS monthly_claim_amount
    FROM claims
    GROUP BY TO_CHAR(claim_date, 'YYYY-MM')
)
ORDER BY claim_month;

/* 19) Denial rate by provider */
SELECT
    c.provider_id,
    p.provider_name,
    COUNT(*) AS total_claims,
    COUNT(CASE WHEN c.status = 'Denied' THEN 1 END) AS denied_claims,
    ROUND(
        COUNT(CASE WHEN c.status = 'Denied' THEN 1 END) * 100 / COUNT(*),
        2
    ) AS denial_rate_pct
FROM claims c
JOIN providers p
    ON c.provider_id = p.provider_id
GROUP BY c.provider_id, p.provider_name
ORDER BY denial_rate_pct DESC, total_claims DESC;

/* 20) Claims with no payment record */
SELECT
    c.claim_id,
    c.patient_id,
    c.provider_id,
    c.claim_amount,
    c.status
FROM claims c
LEFT JOIN payments py
    ON c.claim_id = py.claim_id
WHERE py.claim_id IS NULL
ORDER BY c.claim_id;

/* 21) Patients whose total paid amount exceeds 10000 */
SELECT
    c.patient_id,
    p.patient_name,
    ROUND(SUM(py.paid_amount), 2) AS total_paid_amount
FROM claims c
JOIN payments py
    ON c.claim_id = py.claim_id
JOIN patients p
    ON c.patient_id = p.patient_id
GROUP BY c.patient_id, p.patient_name
HAVING SUM(py.paid_amount) > 10000
ORDER BY total_paid_amount DESC, c.patient_id;

/* 22) Provider performance summary */
SELECT
    c.provider_id,
    p.provider_name,
    p.specialty,
    COUNT(*) AS total_claims,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_amount,
    ROUND(AVG(c.claim_amount), 2) AS avg_claim_amount
FROM claims c
JOIN providers p
    ON c.provider_id = p.provider_id
GROUP BY c.provider_id, p.provider_name, p.specialty
ORDER BY total_claim_amount DESC, c.provider_id;

/* 23) Highest claim in each diagnosis category */
SELECT
    diagnosis_category,
    claim_id,
    patient_id,
    provider_id,
    claim_amount
FROM (
    SELECT
        c.diagnosis_category,
        c.claim_id,
        c.patient_id,
        c.provider_id,
        c.claim_amount,
        ROW_NUMBER() OVER (
            PARTITION BY c.diagnosis_category
            ORDER BY c.claim_amount DESC, c.claim_id
        ) AS rn
    FROM claims c
)
WHERE rn = 1
ORDER BY diagnosis_category;

/* 24) Claim amount buckets */
SELECT
    CASE
        WHEN claim_amount < 1000 THEN 'Below 1000'
        WHEN claim_amount BETWEEN 1000 AND 4999.99 THEN '1000-4999'
        WHEN claim_amount BETWEEN 5000 AND 9999.99 THEN '5000-9999'
        ELSE '10000 and above'
    END AS claim_bucket,
    COUNT(*) AS claim_count,
    ROUND(SUM(claim_amount), 2) AS total_claim_amount
FROM claims
GROUP BY
    CASE
        WHEN claim_amount < 1000 THEN 'Below 1000'
        WHEN claim_amount BETWEEN 1000 AND 4999.99 THEN '1000-4999'
        WHEN claim_amount BETWEEN 5000 AND 9999.99 THEN '5000-9999'
        ELSE '10000 and above'
    END
ORDER BY claim_count DESC;

/* 25) Full patient-level claims and payments summary */
SELECT
    p.patient_id,
    p.patient_name,
    p.state,
    COUNT(DISTINCT c.claim_id) AS total_claims,
    ROUND(NVL(SUM(c.claim_amount), 0), 2) AS total_claim_amount,
    ROUND(NVL(SUM(py.paid_amount), 0), 2) AS total_paid_amount,
    ROUND(NVL(SUM(c.claim_amount), 0) - NVL(SUM(py.paid_amount), 0), 2) AS outstanding_amount
FROM patients p
LEFT JOIN claims c
    ON p.patient_id = c.patient_id
LEFT JOIN payments py
    ON c.claim_id = py.claim_id
GROUP BY p.patient_id, p.patient_name, p.state
ORDER BY total_claim_amount DESC, p.patient_id;
