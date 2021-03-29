;; giveaway id counter
(define-data-var giveaway-id-nonce uint u0)

;; map to keep track of created giveaways
(define-map giveaways
    {giveaway-id: uint}
    {title: (string-utf8 120), amount: uint, giver: principal}
)

;; map to keep track of people registered
(define-map registrees
    {address: principal, giveaway-id: uint}
    {name: (string-utf8 40)}
)

;; errors
(define-constant ERR_CREATE_GIVEAWAY_FAILED u1)
(define-constant ERR_ALREADY_REGISTERED u2)

(define-read-only (get-giveaway-id-nonce) (var-get giveaway-id-nonce))

;; get a giveaway by id
(define-read-only (get-giveaway (giveaway-id uint))
    (map-get? giveaways {giveaway-id: giveaway-id})
)

(define-private (increment-giveaway-nonce) (var-set giveaway-id-nonce (+ (var-get giveaway-id-nonce) u1)))


;; creates a new giveaway
(define-public (create-giveaway (title (string-utf8 120)) (amount uint))
    (let ((id (var-get giveaway-id-nonce)))
        (increment-giveaway-nonce)
        (asserts! (map-insert giveaways {giveaway-id: id}
            {title: title, amount: amount, giver: tx-sender}) (err ERR_CREATE_GIVEAWAY_FAILED))
        (ok id)
    )
)

;; register for a giveaway
(define-public (register (giveaway-id uint) (name (string-utf8 40))) 
    (asserts! (map-insert registrees {address: tx-sender, giveaway-id: giveaway-id} {name: name}) (err ERR_ALREADY_REGISTERED))
)