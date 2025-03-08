;; Interstellar Resource Tokenization Contract

(define-non-fungible-token galactic-resource uint)

(define-map resource-data
  { token-id: uint }
  {
    resource-type: (string-utf8 64),
    origin-planet: (string-utf8 64),
    quantity: uint,
    rarity: uint,
    owner: principal
  }
)

(define-data-var next-token-id uint u0)

(define-public (tokenize-resource (resource-type (string-utf8 64)) (origin-planet (string-utf8 64)) (quantity uint) (rarity uint))
  (let
    ((new-id (var-get next-token-id)))
    (try! (nft-mint? galactic-resource new-id tx-sender))
    (var-set next-token-id (+ new-id u1))
    (ok (map-set resource-data
      { token-id: new-id }
      {
        resource-type: resource-type,
        origin-planet: origin-planet,
        quantity: quantity,
        rarity: rarity,
        owner: tx-sender
      }
    ))
  )
)

(define-public (transfer-resource (token-id uint) (recipient principal))
  (begin
    (try! (nft-transfer? galactic-resource token-id tx-sender recipient))
    (match (map-get? resource-data { token-id: token-id })
      resource-info
        (ok (map-set resource-data
          { token-id: token-id }
          (merge resource-info { owner: recipient })
        ))
      (err u404)
    )
  )
)

(define-read-only (get-resource-data (token-id uint))
  (map-get? resource-data { token-id: token-id })
)

(define-read-only (calculate-resource-value (token-id uint))
  (match (map-get? resource-data { token-id: token-id })
    resource-info
      (let
        ((base-value (get quantity resource-info))
         (rarity-multiplier (get rarity resource-info)))
        (* base-value rarity-multiplier))
    u0)
)

