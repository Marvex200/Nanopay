;; Nanopay: Simple Tipping Contract
;; Allows users to tip creators in STX
;; Tracks tip records and per-recipient totals
;; Includes admin pause/unpause functionality

(define-constant CONTRACT-OWNER 'SP000000000000000000002Q6VF78) ;; REPLACE before deploy

(define-data-var paused bool false)
(define-data-var next-tip-id uint u0)

;; Map of tip records: { id } -> { from, to, amount, memo, timestamp }
(define-map tips
  { id: uint }
  {
    from: principal,
    to: principal,
    amount: uint,
    memo: (optional (string-ascii 128)),
    timestamp: uint
  })

;; Map of totals per recipient: { who } -> { total: uint }
(define-map totals
  { who: principal }
  { total: uint })

;; Errors
(define-constant ERR-PAUSED u100)
(define-constant ERR-UNAUTHORIZED u101)
(define-constant ERR-ZERO-AMOUNT u102)
(define-constant ERR-STX-TRANSFER u103)
(define-constant ERR-INVALID-MEMO u104)

;; Helpers
(define-read-only (only-owner (who principal))
  (ok (is-eq who CONTRACT-OWNER))
)

(define-private (require-active)
  (begin
    (asserts! (is-eq (var-get paused) false) (err ERR-PAUSED))
    (ok true)
  )
)


(define-private (validate-amount (amount uint))
  (if (> amount u0)
    (ok amount)
    (err ERR-ZERO-AMOUNT)
  )
)

;; Fixed memo validation with proper match syntax

(define-private (validate-memo (m (optional (string-ascii 128))))
  (match m
    some-memo (if (> (len some-memo) u0)
      (ok m)
      (err ERR-INVALID-MEMO)
    )
    (ok m)
  )
)

;; Admin
(define-public (set-paused (flag bool))
  (begin
    (asserts! (unwrap-panic (only-owner tx-sender)) (err ERR-UNAUTHORIZED))
    (var-set paused flag)
    (ok flag)
  )
)

;; Fixed main tipping function with correct match syntax and proper variable names

(define-public (tip (recipient principal) (amount uint) (memo (optional (string-ascii 128))))
  (begin
    (try! (require-active))
    (asserts! (> amount u0) (err ERR-ZERO-AMOUNT))
    (match memo
      some-memo (asserts! (> (len some-memo) u0) (err ERR-INVALID-MEMO))
      true
    )
    (match (stx-transfer? amount tx-sender recipient)
      transfer-ok
      (let (
        (tid (+ (var-get next-tip-id) u1))
        (ts stacks-block-height)
      )
        (map-set tips { id: tid }
          { from: tx-sender, to: recipient, amount: amount, memo: memo, timestamp: ts })
        (let ((existing (map-get? totals { who: recipient })))
          (match existing
            some-total (map-set totals { who: recipient } { total: (+ (get total some-total) amount) })
            (map-set totals { who: recipient } { total: amount })
          )
        )
        (var-set next-tip-id tid)
        (ok tid)
      )
      transfer-err
      (err ERR-STX-TRANSFER)
    )
  )
)

;; Read-only views
(define-read-only (get-tip (id uint))
  (map-get? tips { id: id })
)

(define-read-only (get-total-received (who principal))
  (match (map-get? totals { who: who })
    some-record (ok (get total some-record))
    (ok u0)
  )
)

(define-read-only (get-next-tip-id)
  (ok (var-get next-tip-id))
)

(define-read-only (is-paused)
  (ok (var-get paused))
)
