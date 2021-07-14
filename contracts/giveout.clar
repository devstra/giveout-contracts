;; errors
(define-constant ERR_CREATE_GIVEAWAY_FAILED u1)
(define-constant ERR_ALREADY_REGISTERED u2)
(define-constant ERR_MAX_PARTICIPANTS_REACHED u3)

;; giveaway id counter
(define-data-var giveaway-nonce uint u0)

;; map to keep track of created giveaways
(define-map giveaways
    {id: uint}
    {title: (string-utf8 120),
    amount: uint,
    creator: principal,
    participants: (list 10 principal)}
)

(define-read-only (get-giveaway-nonce) (var-get giveaway-nonce))

;; get a giveaway by id
(define-read-only (get-giveaway (giveaway-id uint))
    (map-get? giveaways {id: giveaway-id})
)

;; increments the giveaway ID counter
(define-private (increment-giveaway-nonce) (var-set giveaway-nonce (+ (var-get giveaway-nonce) u1)))

;; checks if an address has already participated in a given giveaway
;; (define-private (participates-in-giveaway (address principal) (id uint)) 
;;     (map-get? participants {address: address, giveaway-id: id})
;; )

;; (define-private (get-participants-in-giveaway (giveaway-id uint)) 
;; ;; need to use list rather than map
;; )


;; creates a new giveaway
(define-public (create-giveaway (title (string-utf8 120)) (amount uint))
    (let ((id (var-get giveaway-nonce)))
        (increment-giveaway-nonce)
        (asserts! (map-insert giveaways {id: id}
            {title: title, amount: amount, creator: tx-sender,
            participants: (list)}) (err ERR_CREATE_GIVEAWAY_FAILED))
        (ok id)
    )
)

;; join a giveaway
(define-public (join-giveaway (giveaway-id uint)) 
    (asserts! (map-set giveaways {id: giveaway-id} {}) (err ERR_ALREADY_REGISTERED))
)