;; errors
(define-constant ERR_CREATE_GIVEAWAY_FAILED u1)
(define-constant ERR_ALREADY_REGISTERED u2)
(define-constant ERR_MAX_PARTICIPANTS_REACHED u3)

;; giveaway id counter
(define-data-var giveaway-id-nonce uint u0)

;; map to keep track of created giveaways
(define-map giveaways
    {giveaway-id: uint}
    {title: (string-utf8 120),
    amount: uint,
    organiser: principal,
    max-participants: uint}
)

;; map to keep track of participants
(define-map participants
    {address: principal, giveaway-id: uint}
    {name: (string-utf8 40)}
)

(define-read-only (get-giveaway-id-nonce) (var-get giveaway-id-nonce))

;; get a giveaway by id
(define-read-only (get-giveaway (giveaway-id uint))
    (map-get? giveaways {giveaway-id: giveaway-id})
)

;; increments the giveaway ID counter
(define-private (increment-giveaway-nonce) (var-set giveaway-id-nonce (+ (var-get giveaway-id-nonce) u1)))

;; checks if an address has already participated in a given giveaway
(define-private (participates-in-giveaway (address principal) (id uint)) 
    (map-get? participants {address: address, giveaway-id: id})
)

(define-private (get-participants-in-giveaway (giveaway-id uint)) 
;; need to use list rather than map
)


;; creates a new giveaway
(define-public (create-giveaway (title (string-utf8 120)) (amount uint)
    (max-participants uint))
    (let ((id (var-get giveaway-id-nonce)))
        (increment-giveaway-nonce)
        (asserts! (map-insert giveaways {giveaway-id: id}
            {title: title, amount: amount, organiser: tx-sender,
            max-participants: max-participants}) (err ERR_CREATE_GIVEAWAY_FAILED))
        (ok id)
    )
)

;; participate in a giveaway
(define-public (participate (giveaway-id uint) (name (string-utf8 40))) 
    (asserts! (map-insert participants {address: tx-sender, giveaway-id: giveaway-id} {name: name}) (err ERR_ALREADY_REGISTERED))
)