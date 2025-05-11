;; Institution Verification Contract
;; Validates financial entities participating in the system

(define-data-var admin principal tx-sender)

;; Map to store verified institutions
(define-map verified-institutions principal
  {
    name: (string-ascii 64),
    verification-date: uint,
    status: (string-ascii 10),
    verification-level: uint
  }
)

;; Add a new institution to the verified list
(define-public (register-institution (institution-principal principal) (name (string-ascii 64)) (verification-level uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (not (is-some (map-get? verified-institutions institution-principal))) (err u100))
    (ok (map-set verified-institutions
                institution-principal
                {
                  name: name,
                  verification-date: block-height,
                  status: "active",
                  verification-level: verification-level
                }))
  )
)

;; Check if an institution is verified
(define-read-only (is-verified (institution-principal principal))
  (match (map-get? verified-institutions institution-principal)
    institution (and (is-eq (get status institution) "active") true)
    false
  )
)

;; Get institution details
(define-read-only (get-institution-details (institution-principal principal))
  (map-get? verified-institutions institution-principal)
)

;; Suspend an institution
(define-public (suspend-institution (institution-principal principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? verified-institutions institution-principal)
      institution (ok (map-set verified-institutions
                              institution-principal
                              (merge institution {status: "suspended"})))
      (err u404)
    )
  )
)

;; Reactivate a suspended institution
(define-public (reactivate-institution (institution-principal principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? verified-institutions institution-principal)
      institution (ok (map-set verified-institutions
                              institution-principal
                              (merge institution {status: "active"})))
      (err u404)
    )
  )
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
