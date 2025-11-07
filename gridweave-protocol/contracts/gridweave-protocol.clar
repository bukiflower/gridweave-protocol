;; GridWeave Protocol - Decentralized Utilities Infrastructure Platform
;; A blockchain-based system for managing energy, water, and data distribution through micro-grids

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-RESOURCE (err u101))
(define-constant ERR-INSUFFICIENT-STAKE (err u102))
(define-constant ERR-GRID-NOT-FOUND (err u103))
(define-constant ERR-INVALID-AMOUNT (err u104))
(define-constant ERR-ALREADY-EXISTS (err u105))
(define-constant ERR-TRANSFER-FAILED (err u106))

;; Minimum stake required for grid governance (1000 tokens)
(define-constant MIN-STAKE-AMOUNT u1000000000)

;; Resource types
(define-constant RESOURCE-ENERGY u1)
(define-constant RESOURCE-WATER u2)
(define-constant RESOURCE-DATA u3)

;; Data Variables
(define-data-var protocol-active bool true)
(define-data-var total-grids uint u0)
(define-data-var total-resources-tracked uint u0)
(define-data-var global-efficiency-score uint u0)

;; Data Maps

;; Micro-grid registry
(define-map micro-grids
    { grid-id: uint }
    {
        operator: principal,
        location-hash: (buff 32),
        active: bool,
        total-capacity: uint,
        current-load: uint,
        efficiency-score: uint,
        carbon-footprint: uint,
        created-at: uint
    }
)

;; Resource DNA tracking
(define-map resource-dna
    { resource-id: uint }
    {
        resource-type: uint,
        grid-id: uint,
        generation-method: (string-ascii 50),
        carbon-footprint: uint,
        harmony-metric: uint,
        origin-timestamp: uint,
        metadata-hash: (buff 32)
    }
)

;; Temporal grid staking
(define-map grid-stakes
    { staker: principal, grid-id: uint }
    {
        amount: uint,
        staked-at: uint,
        governance-power: uint,
        rewards-earned: uint
    }
)

;; Grid operator performance
(define-map operator-stats
    { operator: principal }
    {
        grids-operated: uint,
        total-efficiency: uint,
        innovations-adopted: uint,
        reputation-score: uint
    }
)

;; Resource cascade routing (grid interconnections)
(define-map grid-connections
    { from-grid: uint, to-grid: uint }
    {
        capacity: uint,
        active: bool,
        total-transferred: uint
    }
)

;; Seasonal challenge participation
(define-map challenge-participants
    { participant: principal, season: uint }
    {
        efficiency-improvement: uint,
        rewards-claimed: uint,
        rank: uint
    }
)

;; Read-only functions

(define-read-only (get-micro-grid (grid-id uint))
    (map-get? micro-grids { grid-id: grid-id })
)

(define-read-only (get-resource-dna (resource-id uint))
    (map-get? resource-dna { resource-id: resource-id })
)

(define-read-only (get-grid-stake (staker principal) (grid-id uint))
    (map-get? grid-stakes { staker: staker, grid-id: grid-id })
)

(define-read-only (get-operator-stats (operator principal))
    (map-get? operator-stats { operator: operator })
)

(define-read-only (get-grid-connection (from-grid uint) (to-grid uint))
    (map-get? grid-connections { from-grid: from-grid, to-grid: to-grid })
)

(define-read-only (get-protocol-status)
    {
        active: (var-get protocol-active),
        total-grids: (var-get total-grids),
        total-resources: (var-get total-resources-tracked),
        global-efficiency: (var-get global-efficiency-score)
    }
)

(define-read-only (calculate-governance-power (stake-amount uint) (duration uint))
    (/ (* stake-amount duration) u1000000)
)

(define-read-only (get-grid-efficiency (grid-id uint))
    (match (map-get? micro-grids { grid-id: grid-id })
        grid (ok (get efficiency-score grid))
        ERR-GRID-NOT-FOUND
    )
)

;; Public functions

;; Register a new micro-grid
(define-public (register-micro-grid (location-hash (buff 32)) (initial-capacity uint))
    (let
        (
            (new-grid-id (+ (var-get total-grids) u1))
            (current-block block-height)
        )
        (asserts! (var-get protocol-active) ERR-NOT-AUTHORIZED)
        (asserts! (> initial-capacity u0) ERR-INVALID-AMOUNT)
        
        (map-set micro-grids
            { grid-id: new-grid-id }
            {
                operator: tx-sender,
                location-hash: location-hash,
                active: true,
                total-capacity: initial-capacity,
                current-load: u0,
                efficiency-score: u100,
                carbon-footprint: u0,
                created-at: current-block
            }
        )
        
        ;; Update operator stats
        (match (map-get? operator-stats { operator: tx-sender })
            existing-stats
                (map-set operator-stats
                    { operator: tx-sender }
                    (merge existing-stats { grids-operated: (+ (get grids-operated existing-stats) u1) })
                )
            (map-set operator-stats
                { operator: tx-sender }
                {
                    grids-operated: u1,
                    total-efficiency: u0,
                    innovations-adopted: u0,
                    reputation-score: u100
                }
            )
        )
        
        (var-set total-grids new-grid-id)
        (ok new-grid-id)
    )
)

;; Track resource with DNA metadata
(define-public (track-resource 
    (resource-type uint)
    (grid-id uint)
    (generation-method (string-ascii 50))
    (carbon-footprint uint)
    (harmony-metric uint)
    (metadata-hash (buff 32)))
    (let
        (
            (resource-id (+ (var-get total-resources-tracked) u1))
            (current-block block-height)
        )
        (asserts! (var-get protocol-active) ERR-NOT-AUTHORIZED)
        (asserts! (is-some (map-get? micro-grids { grid-id: grid-id })) ERR-GRID-NOT-FOUND)
        (asserts! (or (is-eq resource-type RESOURCE-ENERGY) 
                     (or (is-eq resource-type RESOURCE-WATER) 
                         (is-eq resource-type RESOURCE-DATA))) ERR-INVALID-RESOURCE)
        
        (map-set resource-dna
            { resource-id: resource-id }
            {
                resource-type: resource-type,
                grid-id: grid-id,
                generation-method: generation-method,
                carbon-footprint: carbon-footprint,
                harmony-metric: harmony-metric,
                origin-timestamp: current-block,
                metadata-hash: metadata-hash
            }
        )
        
        (var-set total-resources-tracked resource-id)
        (ok resource-id)
    )
)

;; Stake tokens for grid governance
(define-public (stake-for-governance (grid-id uint) (amount uint))
    (let
        (
            (current-block block-height)
            (governance-power (calculate-governance-power amount u1))
        )
        (asserts! (var-get protocol-active) ERR-NOT-AUTHORIZED)
        (asserts! (is-some (map-get? micro-grids { grid-id: grid-id })) ERR-GRID-NOT-FOUND)
        (asserts! (>= amount MIN-STAKE-AMOUNT) ERR-INSUFFICIENT-STAKE)
        
        ;; Note: In production, implement actual STX transfer here
        ;; (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        (match (map-get? grid-stakes { staker: tx-sender, grid-id: grid-id })
            existing-stake
                (map-set grid-stakes
                    { staker: tx-sender, grid-id: grid-id }
                    (merge existing-stake { 
                        amount: (+ (get amount existing-stake) amount),
                        governance-power: (+ (get governance-power existing-stake) governance-power)
                    })
                )
            (map-set grid-stakes
                { staker: tx-sender, grid-id: grid-id }
                {
                    amount: amount,
                    staked-at: current-block,
                    governance-power: governance-power,
                    rewards-earned: u0
                }
            )
        )
        
        (ok true)
    )
)

;; Update grid efficiency score
(define-public (update-grid-efficiency (grid-id uint) (new-efficiency uint))
    (let
        (
            (grid-data (unwrap! (map-get? micro-grids { grid-id: grid-id }) ERR-GRID-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender (get operator grid-data)) ERR-NOT-AUTHORIZED)
        (asserts! (<= new-efficiency u1000) ERR-INVALID-AMOUNT)
        
        (map-set micro-grids
            { grid-id: grid-id }
            (merge grid-data { efficiency-score: new-efficiency })
        )
        
        (ok true)
    )
)

;; Establish grid connection for resource cascade
(define-public (connect-grids (from-grid uint) (to-grid uint) (capacity uint))
    (let
        (
            (from-grid-data (unwrap! (map-get? micro-grids { grid-id: from-grid }) ERR-GRID-NOT-FOUND))
            (to-grid-data (unwrap! (map-get? micro-grids { grid-id: to-grid }) ERR-GRID-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender (get operator from-grid-data)) ERR-NOT-AUTHORIZED)
        (asserts! (> capacity u0) ERR-INVALID-AMOUNT)
        
        (map-set grid-connections
            { from-grid: from-grid, to-grid: to-grid }
            {
                capacity: capacity,
                active: true,
                total-transferred: u0
            }
        )
        
        (ok true)
    )
)

;; Transfer resources between connected grids
(define-public (cascade-resources (from-grid uint) (to-grid uint) (amount uint))
    (let
        (
            (connection (unwrap! (map-get? grid-connections { from-grid: from-grid, to-grid: to-grid }) ERR-GRID-NOT-FOUND))
            (from-grid-data (unwrap! (map-get? micro-grids { grid-id: from-grid }) ERR-GRID-NOT-FOUND))
        )
        (asserts! (get active connection) ERR-NOT-AUTHORIZED)
        (asserts! (<= amount (get capacity connection)) ERR-INVALID-AMOUNT)
        (asserts! (is-eq tx-sender (get operator from-grid-data)) ERR-NOT-AUTHORIZED)
        
        ;; Update connection stats
        (map-set grid-connections
            { from-grid: from-grid, to-grid: to-grid }
            (merge connection { total-transferred: (+ (get total-transferred connection) amount) })
        )
        
        (ok true)
    )
)

;; Record innovation adoption
(define-public (record-innovation-adoption (innovator principal))
    (let
        (
            (stats (default-to 
                {
                    grids-operated: u0,
                    total-efficiency: u0,
                    innovations-adopted: u0,
                    reputation-score: u100
                }
                (map-get? operator-stats { operator: innovator })
            ))
        )
        (map-set operator-stats
            { operator: innovator }
            (merge stats { 
                innovations-adopted: (+ (get innovations-adopted stats) u1),
                reputation-score: (+ (get reputation-score stats) u10)
            })
        )
        
        (ok true)
    )
)

;; Participate in seasonal efficiency challenge
(define-public (join-seasonal-challenge (season uint) (efficiency-improvement uint))
    (begin
        (asserts! (var-get protocol-active) ERR-NOT-AUTHORIZED)
        
        (map-set challenge-participants
            { participant: tx-sender, season: season }
            {
                efficiency-improvement: efficiency-improvement,
                rewards-claimed: u0,
                rank: u0
            }
        )
        
        (ok true)
    )
)

;; Administrative functions

(define-public (toggle-protocol-status)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set protocol-active (not (var-get protocol-active)))
        (ok (var-get protocol-active))
    )
)

(define-public (update-global-efficiency (new-score uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set global-efficiency-score new-score)
        (ok true)
    )
)
