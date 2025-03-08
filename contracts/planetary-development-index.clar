;; Planetary Development Index Contract

(define-map planets
  { id: (string-utf8 64) }
  {
    name: (string-utf8 64),
    sector: (string-utf8 64),
    development-index: uint,
    resources: (list 10 uint),
    last-updated: uint
  }
)

(define-map development-metrics
  { planet-id: (string-utf8 64), metric-id: (string-utf8 32) }
  { value: uint }
)

(define-public (register-planet (id (string-utf8 64)) (name (string-utf8 64)) (sector (string-utf8 64)))
  (ok (map-set planets
    { id: id }
    {
      name: name,
      sector: sector,
      development-index: u0,
      resources: (list),
      last-updated: block-height
    }
  ))
)

(define-public (update-development-metric (planet-id (string-utf8 64)) (metric-id (string-utf8 32)) (value uint))
  (begin
    (map-set development-metrics
      { planet-id: planet-id, metric-id: metric-id }
      { value: value }
    )
    (ok (update-development-index planet-id))
  )
)

(define-public (add-planet-resource (planet-id (string-utf8 64)) (token-id uint))
  (match (map-get? planets { id: planet-id })
    planet
      (ok (map-set planets
        { id: planet-id }
        (merge planet {
          resources: (unwrap! (as-max-len? (append (get resources planet) token-id) u10) (err u400)),
          last-updated: block-height
        })
      ))
    (err u404)
  )
)

(define-read-only (get-planet (planet-id (string-utf8 64)))
  (map-get? planets { id: planet-id })
)

(define-read-only (get-development-metric (planet-id (string-utf8 64)) (metric-id (string-utf8 32)))
  (default-to { value: u0 } (map-get? development-metrics { planet-id: planet-id, metric-id: metric-id }))
)

(define-private (update-development-index (planet-id (string-utf8 64)))
  (match (map-get? planets { id: planet-id })
    planet
      (let
        ((new-index (calculate-development-index planet-id)))
        (map-set planets
          { id: planet-id }
          (merge planet {
            development-index: new-index,
            last-updated: block-height
          })
        ))
    false)
)

(define-private (calculate-development-index (planet-id (string-utf8 64)))
  ;; In a real implementation, this would aggregate all development metrics
  ;; For simplicity, we'll just return a placeholder value
  u750
)

