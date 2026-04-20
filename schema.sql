/* =========================================================
   Healthcare Claims & Cost Analysis - schema.sql (Oracle)
   ========================================================= */

CREATE TABLE patients (
    patient_id      NUMBER PRIMARY KEY,
    patient_name    VARCHAR2(100),
    age             NUMBER,
    gender          VARCHAR2(20),
    state           VARCHAR2(10)
);

CREATE TABLE providers (
    provider_id     NUMBER PRIMARY KEY,
    provider_name   VARCHAR2(100),
    specialty       VARCHAR2(100),
    state           VARCHAR2(10)
);

CREATE TABLE claims (
    claim_id             NUMBER PRIMARY KEY,
    patient_id           NUMBER,
    provider_id          NUMBER,
    claim_amount         NUMBER(12,2),
    claim_date           DATE,
    status               VARCHAR2(20),
    diagnosis_category   VARCHAR2(50),
    CONSTRAINT fk_claims_patient
        FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_claims_provider
        FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
);

CREATE TABLE payments (
    payment_id       NUMBER PRIMARY KEY,
    claim_id         NUMBER,
    paid_amount      NUMBER(12,2),
    payment_date     DATE,
    payment_method   VARCHAR2(20),
    CONSTRAINT fk_payments_claim
        FOREIGN KEY (claim_id) REFERENCES claims(claim_id)
);

CREATE INDEX idx_claims_patient ON claims(patient_id);
CREATE INDEX idx_claims_provider ON claims(provider_id);
CREATE INDEX idx_claims_date ON claims(claim_date);
CREATE INDEX idx_claims_status ON claims(status);
CREATE INDEX idx_payments_claim ON payments(claim_id);
