# GridWeave Protocol - Smart Contract Documentation

## Overview

GridWeave Protocol is a revolutionary decentralized utilities infrastructure platform built on the Stacks blockchain. It transforms how energy, water, and data are distributed through AI-powered micro-grid orchestration, enabling communities to create efficient, sustainable utility networks with transparent resource tracking and intelligent optimization.

## Core Features

### 🔋 Resource DNA Technology
Every utility unit carries immutable metadata tracking:
- Generation method and origin
- Carbon footprint signature
- Grid harmony metrics
- Performance characteristics
- Temporal efficiency data

### 🏛️ Temporal Grid Staking
Community members can stake tokens to:
- Gain governance rights over local resource allocation
- Earn rewards tied to actual efficiency improvements
- Participate in grid optimization decisions
- Build reputation through sustainable practices

### 🌐 Resource Cascade Optimization
Smart contracts dynamically:
- Redistribute excess capacity between neighboring grids
- Execute automated load balancing
- Track resource transfers with full transparency
- Optimize network-wide efficiency

### 🎮 Gamified Seasonal Challenges
The platform incentivizes innovation through:
- Competitive efficiency improvement contests
- Protocol token rewards for top performers
- Community-driven sustainability goals
- Reputation building for innovative operators

## Smart Contract Architecture

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `MIN-STAKE-AMOUNT` | 1000000000 | Minimum tokens required for governance staking (1000 STX) |
| `RESOURCE-ENERGY` | 1 | Energy resource type identifier |
| `RESOURCE-WATER` | 2 | Water resource type identifier |
| `RESOURCE-DATA` | 3 | Data/bandwidth resource type identifier |

### Error Codes

| Code | Name | Description |
|------|------|-------------|
| u100 | ERR-NOT-AUTHORIZED | User lacks permission for operation |
| u101 | ERR-INVALID-RESOURCE | Invalid resource type specified |
| u102 | ERR-INSUFFICIENT-STAKE | Stake amount below minimum threshold |
| u103 | ERR-GRID-NOT-FOUND | Referenced grid does not exist |
| u104 | ERR-INVALID-AMOUNT | Invalid amount parameter |
| u105 | ERR-ALREADY-EXISTS | Entity already registered |
| u106 | ERR-TRANSFER-FAILED | Token transfer failed |

## Data Structures

### Micro-Grid Registry
```clarity
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
```

Stores core information about each registered micro-grid including operator, capacity, and performance metrics.

### Resource DNA
```clarity
{
    resource-type: uint,
    grid-id: uint,
    generation-method: (string-ascii 50),
    carbon-footprint: uint,
    harmony-metric: uint,
    origin-timestamp: uint,
    metadata-hash: (buff 32)
}
```

Tracks the complete lineage and characteristics of each utility resource unit.

### Grid Stakes
```clarity
{
    amount: uint,
    staked-at: uint,
    governance-power: uint,
    rewards-earned: uint
}
```

Records staking positions for governance participation and reward distribution.

### Operator Statistics
```clarity
{
    grids-operated: uint,
    total-efficiency: uint,
    innovations-adopted: uint,
    reputation-score: uint
}
```

Maintains performance and reputation metrics for grid operators.

### Grid Connections
```clarity
{
    capacity: uint,
    active: bool,
    total-transferred: uint
}
```

Manages interconnections between micro-grids for resource cascade optimization.

## Public Functions

### Grid Management

#### `register-micro-grid`
```clarity
(register-micro-grid (location-hash (buff 32)) (initial-capacity uint))
```

Registers a new micro-grid in the protocol.

**Parameters:**
- `location-hash`: Cryptographic hash of grid location (privacy-preserved)
- `initial-capacity`: Initial resource capacity of the grid

**Returns:** Grid ID (uint)

**Example:**
```clarity
(contract-call? .gridweave-protocol register-micro-grid 0x1234... u5000000)
```

#### `update-grid-efficiency`
```clarity
(update-grid-efficiency (grid-id uint) (new-efficiency uint))
```

Updates the efficiency score for a grid (operator only).

**Parameters:**
- `grid-id`: Target grid identifier
- `new-efficiency`: New efficiency score (0-1000 scale)

**Authorization:** Grid operator only

---

### Resource Tracking

#### `track-resource`
```clarity
(track-resource 
    (resource-type uint)
    (grid-id uint)
    (generation-method (string-ascii 50))
    (carbon-footprint uint)
    (harmony-metric uint)
    (metadata-hash (buff 32)))
```

Tracks a utility resource with complete DNA metadata.

**Parameters:**
- `resource-type`: Type of resource (1=Energy, 2=Water, 3=Data)
- `grid-id`: Source grid identifier
- `generation-method`: Method used to generate/acquire resource
- `carbon-footprint`: Carbon emissions metric
- `harmony-metric`: Grid harmony compatibility score
- `metadata-hash`: Hash of extended metadata

**Returns:** Resource ID (uint)

**Example:**
```clarity
(contract-call? .gridweave-protocol track-resource 
    u1 
    u1 
    "solar-photovoltaic" 
    u25 
    u950 
    0xabcd...)
```

---

### Staking & Governance

#### `stake-for-governance`
```clarity
(stake-for-governance (grid-id uint) (amount uint))
```

Stake tokens to gain governance rights over a specific grid.

**Parameters:**
- `grid-id`: Target grid for governance participation
- `amount`: Amount to stake (minimum 1000 STX)

**Requirements:**
- Amount must meet or exceed `MIN-STAKE-AMOUNT`
- Grid must exist

**Example:**
```clarity
(contract-call? .gridweave-protocol stake-for-governance u1 u1000000000)
```

---

### Grid Interconnection

#### `connect-grids`
```clarity
(connect-grids (from-grid uint) (to-grid uint) (capacity uint))
```

Establishes a connection between two grids for resource sharing.

**Parameters:**
- `from-grid`: Source grid ID
- `to-grid`: Destination grid ID
- `capacity`: Maximum transfer capacity

**Authorization:** Source grid operator only

#### `cascade-resources`
```clarity
(cascade-resources (from-grid uint) (to-grid uint) (amount uint))
```

Transfers resources between connected grids.

**Parameters:**
- `from-grid`: Source grid ID
- `to-grid`: Destination grid ID
- `amount`: Amount to transfer

**Requirements:**
- Grids must be connected
- Amount must not exceed connection capacity
- Caller must be source grid operator

---

### Innovation & Reputation

#### `record-innovation-adoption`
```clarity
(record-innovation-adoption (innovator principal))
```

Records when an innovation from one operator is adopted by another grid.

**Parameters:**
- `innovator`: Principal address of the innovating operator

**Effect:** Increases innovator's reputation score and adoption count.

#### `join-seasonal-challenge`
```clarity
(join-seasonal-challenge (season uint) (efficiency-improvement uint))
```

Register participation in a seasonal efficiency challenge.

**Parameters:**
- `season`: Challenge season identifier
- `efficiency-improvement`: Claimed efficiency improvement percentage

---

## Read-Only Functions

### `get-micro-grid`
```clarity
(get-micro-grid (grid-id uint))
```
Returns complete information about a specific micro-grid.

### `get-resource-dna`
```clarity
(get-resource-dna (resource-id uint))
```
Returns DNA metadata for a tracked resource.

### `get-grid-stake`
```clarity
(get-grid-stake (staker principal) (grid-id uint))
```
Returns staking information for a specific staker and grid.

### `get-operator-stats`
```clarity
(get-operator-stats (operator principal))
```
Returns performance statistics for a grid operator.

### `get-grid-connection`
```clarity
(get-grid-connection (from-grid uint) (to-grid uint))
```
Returns connection details between two grids.

### `get-protocol-status`
```clarity
(get-protocol-status)
```
Returns overall protocol statistics including total grids, resources, and global efficiency.

### `calculate-governance-power`
```clarity
(calculate-governance-power (stake-amount uint) (duration uint))
```
Calculates governance power based on stake amount and duration.

### `get-grid-efficiency`
```clarity
(get-grid-efficiency (grid-id uint))
```
Returns the efficiency score for a specific grid.

---

## Administrative Functions

### `toggle-protocol-status`
```clarity
(toggle-protocol-status)
```
Enables or disables the protocol (contract owner only).

### `update-global-efficiency`
```clarity
(update-global-efficiency (new-score uint))
```
Updates the global efficiency score metric (contract owner only).

---

## Usage Examples

### Example 1: Setting Up a New Solar Micro-Grid

```clarity
;; Step 1: Register the micro-grid
(contract-call? .gridweave-protocol register-micro-grid 
    0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb5  ;; Location hash
    u10000000)  ;; 10MW capacity
;; Returns: (ok u1) - Grid ID 1 created

;; Step 2: Track solar energy production
(contract-call? .gridweave-protocol track-resource
    u1  ;; Energy type
    u1  ;; Grid ID
    "solar-photovoltaic"
    u15  ;; Low carbon footprint
    u980  ;; High harmony metric
    0x9fe2076a9b3f0c5e0c8a12345678abcdef...)
;; Returns: (ok u1) - Resource ID 1 tracked

;; Step 3: Community member stakes for governance
(contract-call? .gridweave-protocol stake-for-governance
    u1  ;; Grid ID
    u2000000000)  ;; 2000 STX stake
;; Returns: (ok true) - Stake successful
```

### Example 2: Connecting Grids for Resource Sharing

```clarity
;; Grid operator connects to neighboring grid
(contract-call? .gridweave-protocol connect-grids
    u1  ;; From grid (solar)
    u2  ;; To grid (community)
    u5000000)  ;; 5MW transfer capacity
;; Returns: (ok true) - Connection established

;; Transfer excess solar capacity
(contract-call? .gridweave-protocol cascade-resources
    u1  ;; From solar grid
    u2  ;; To community grid
    u3000000)  ;; 3MW transfer
;; Returns: (ok true) - Resources transferred
```

### Example 3: Tracking Innovation Adoption

```clarity
;; Record when an operator's efficiency innovation is adopted
(contract-call? .gridweave-protocol record-innovation-adoption
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
;; Returns: (ok true) - Innovation recorded, reputation increased
```

---

## Integration Guidelines

### Smart Meter Integration
GridWeave is designed to integrate with existing IoT infrastructure:

1. **Data Collection**: Use off-chain services to collect meter data
2. **Batch Processing**: Aggregate readings before blockchain submission
3. **Hash Verification**: Store data hashes on-chain for verification
4. **Resource Tracking**: Call `track-resource` for significant resource units

### Zero-Knowledge Proof Integration
For sensitive infrastructure data:

1. Generate ZK proofs off-chain for efficiency claims
2. Store proof verification hashes in `metadata-hash` fields
3. Allow validators to verify without revealing sensitive data
4. Use for competitive advantage protection

### AI Attribution Engine
The protocol supports AI-powered optimization:

1. AI analyzes grid configurations off-chain
2. Successful patterns are encoded and shared
3. `record-innovation-adoption` tracks usage across grids
4. Rewards distributed based on adoption metrics

---

## Security Considerations

### Access Control
- Grid operations restricted to registered operators
- Staking requirements prevent spam governance
- Connection establishment requires mutual agreement
- Administrative functions limited to contract owner

### Data Privacy
- Location data stored as cryptographic hashes
- Sensitive metrics protected with zero-knowledge proofs
- Resource metadata stored off-chain with on-chain verification
- Grid connections visible but capacity private

### Economic Security
- Minimum stake requirements prevent Sybil attacks
- Reputation scores create long-term incentive alignment
- Efficiency improvements verified through oracle integration
- Cascade optimization prevents resource manipulation

---

## Deployment Instructions

### Prerequisites
- Stacks blockchain node access
- Clarinet development environment
- STX tokens for deployment

### Deployment Steps

1. **Clone Repository**
```bash
git clone <repository-url>
cd gridweave-protocol
```

2. **Validate Contract**
```bash
clarinet check
```

3. **Deploy to Testnet**
```bash
clarinet deploy --testnet
```

4. **Deploy to Mainnet**
```bash
clarinet deploy --mainnet
```

### Post-Deployment Configuration

1. Verify contract deployment on Stacks Explorer
2. Initialize first micro-grid for testing
3. Configure off-chain services for IoT integration
4. Set up monitoring for protocol metrics

---

## Roadmap

### Phase 1: Core Infrastructure (Current)
- ✅ Basic grid registration
- ✅ Resource DNA tracking
- ✅ Temporal staking mechanism
- ✅ Grid interconnection framework

### Phase 2: Advanced Features
- 🔄 Oracle integration for real-time pricing
- 🔄 Automated cascade optimization algorithms
- 🔄 Enhanced governance mechanisms
- 🔄 Cross-chain bridge support

### Phase 3: Ecosystem Expansion
- 📋 Mobile app for community members
- 📋 Creative Grid Composer UI
- 📋 AI attribution marketplace
- 📋 Carbon credit tokenization

### Phase 4: Scale & Optimization
- 📋 Layer 2 scaling solutions
- 📋 Advanced privacy features
- 📋 Interoperability with energy markets
- 📋 Regulatory compliance frameworks

---

## Contributing

We welcome contributions from the community! Areas of focus:

- **Smart Contract Optimization**: Improve gas efficiency
- **Security Audits**: Identify and fix vulnerabilities
- **Documentation**: Enhance guides and examples
- **Integration Tools**: Build connectors for IoT platforms
- **UI/UX**: Design intuitive interfaces

Please submit pull requests or open issues on our GitHub repository.

---

## Acknowledgments

Built on Stacks blockchain with inspiration from:
- Decentralized energy grid research
- Sustainable community initiatives
- Open-source blockchain innovations
- Climate change mitigation efforts

---

**GridWeave Protocol** - Powering the future of decentralized utilities infrastructure 🌍⚡💧
