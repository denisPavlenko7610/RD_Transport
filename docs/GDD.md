# RD_Transport — Game Design Document

**Status:** Design baseline. The Unity project and shared-module links are set up. The gameplay below is planned.
Quantities, platform priorities, and timings are prototype assumptions.

## 1. Vision

Build a regional freight carrier that grows from a single depot into a network of scheduled routes. The player's job is
to decide which contracts their network can reliably serve, where freight should transfer, and how to make a vehicle
earn money in both directions.

*Logis Tycoon Evolution* is the genre reference for map-based dispatch, freight collection and distribution, transfer
hubs, fleet upgrades, and eventual air freight. RD_Transport takes place in an original coastal region with its own
cities, clients, economy, and cartography. Its signature decisions come from standing routes, paid backhauls, and
transfer capacity. All visual assets, screens, text, map layouts, and numerical balance are authored for this
project. [Reference description supplied by Macaron](https://www.thegreatapps.com/apps/logis-tycoon-evolution)

**Target:** Offline single-player logistics tycoon. Prototype on desktop with a landscape map and target touch-friendly
controls for Android. Use 5–15 minute sessions as a playtest target. A company run has regional milestones and can
continue after the final milestone.

## 2. Player loop

1. Read available contracts on the map. Compare freight volume, delivery window, payout, and pickup location.
2. Preview a direct trip or an itinerary through a company hub. Inspect predicted arrival, available capacity, and trip
   margin.
3. Accept the order and manually dispatch a vehicle or assign freight to an existing scheduled route.
4. Track vehicles and queues as the clock runs. Fill a return leg, redirect waiting freight, or adjust the next
   departure when conditions change.
5. Collect the result when the complete order reaches its destination. Reinvest cash in a vehicle, depot throughput, or
   regional access.

**First 10 minutes:** Take a delivery from Alder Quay to North Weir, pick up a compatible return load, and compare the
round-trip results. Unlock the Ridge Junction depot and see how transferring cargo there opens a contract a single truck
cannot serve on time. Turn an established run into a scheduled line after demonstrating the manual flow.

## 3. World and network

- The prototype's six towns have distinct industries and directional demand. Alder Quay ships packaged imports, North
  Weir ships farm produce, and Ridge Junction connects the coast to inland towns. Towns can offer contracts without
  hosting a company depot.
- The map is a graph of towns, facilities, and transport links. Each link specifies mode, distance, travel time, cost,
  and access requirements. Vehicles use existing infrastructure. Depot and airfield upgrades change the company's
  capacity to use it.
- A depot stages freight for transfer. Physical storage determines how much can wait. Handling slots and processing time
  determine how fast freight can be received and dispatched. A transfer must fit both the timetable and the depot's
  available capacity.
- The route preview shows the itinerary, ETA, estimated operating cost, and blocking constraint. It uses the same travel
  and handling rules as dispatch. Limit the prototype to one intermediate depot per shipment and use a stable tie-break
  for equivalent routes.

## 4. Freight, dispatch, and automation

Each order has a stable ID, origin, destination, cargo class, integer volume, pickup availability, deadline, and payout.
Start with dry cargo and chilled cargo. Chilled freight requires a compatible vehicle and chilled storage at any
transfer. Each prototype order travels as one unit.

An order moves from offered to accepted, queued at origin, in transit, optionally waiting at a hub, then settled at its
destination. An offer expires if its acceptance window closes. An accepted order delivered past its deadline still
settles at a reduced payout. Before pickup, the player may cancel for a disclosed fee. In transit, the vehicle completes
its current leg. At the next stop, the player can plan the remaining legs again.

- **Manual dispatch:** Choose the assigned vehicle, stops, and freight. Validate mode, range, volume, cargo
  compatibility, and target depot storage before committing. A vehicle belongs to one active trip at a time. Reserve
  storage for incoming transfers when the relevant leg is dispatched. Release reservations on cancellation or arrival.
- **Standing route:** A line has ordered stops, assigned vehicles, a departure interval, and a loading policy. At
  departure, unload first, then take eligible reserved freight in earliest-deadline order, with order ID breaking ties.
  Use free capacity for eligible backhauls. The player chooses whether to allow an empty departure. Otherwise it holds
  until the next scheduled departure and shows the reason.
- **Backhaul:** Return demand comes from local contracts. The departure preview shows the extra margin and any added
  risk to the promised delivery window. A short wait to consolidate loads or a quick departure to protect a deadline
  should each be viable in different circumstances.
- **Disruptions after the prototype:** Announced road closures, demand surges, and airfield delays create rerouting
  choices. Show affected contracts and revised ETAs, and give the player time to respond.

## 5. Economy and growth

- Use a single cash currency and integer amounts. Deduct operating costs when a leg departs, and charge handling when
  the depot processes the freight. Display these costs even when a vehicle travels empty. Settle a contract once, at its
  destination. Track reputation from on-time and late settlements to unlock clients and towns.
- Prototype balance for one two-leg route. An on-time outward delivery pays 300, each road leg costs 80, and handling is
  20 for the outward order. Returning empty leaves a margin of 120. A compatible backhaul paying 120 with 10 extra
  handling raises the round-trip margin to 230. These are starting values for tuning, independent of progression
  thresholds.
- A small van serves short low-volume trips. A box truck consolidates dry cargo. A reefer unlocks chilled contracts with
  a higher operating cost. Improvements specialize in capacity, efficiency, or travel speed. Increase depot storage and
  handling separately so the player can buy the upgrade that removes the observed bottleneck.
- Start with one depot and one vehicle. Open neighboring towns after demonstrating reliable delivery, then use a second
  depot to serve multi-leg orders. In the next phase, aircraft connect eligible terminals over longer distances. They
  trade higher trip costs and terminal handling time for faster line-haul service. Local trucks still perform pickup and
  final delivery when the contract endpoints are outside the airport towns.
- A cash shortage pauses departures the company cannot afford and shows the shortfall before dispatch. The prototype
  starts with a funded operating reserve. Test a recovery contract for later builds if playtests show players can
  exhaust cash without any remaining decision.

## 6. Interface and presentation

Use an original 2D dispatch map styled as a printed coastal transport chart, with restrained terrain, readable town
markers, and animated route lines. Use color and a separate icon or line pattern for each freight or route status. Keep
movements legible at the region zoom level.

| Surface               | Player task                                                                                        |
|-----------------------|----------------------------------------------------------------------------------------------------|
| Map and HUD           | Inspect towns, depots, and moving vehicles. View available cash, alerts, and pause/1×/2× controls. |
| Contract board        | Filter by origin, deadline, cargo class, and feasibility. Compare payout and projected costs.      |
| Dispatch preview      | Select a vehicle, inspect each leg, confirm capacity, and see the consequences before departure.   |
| Depot and fleet views | Locate waiting orders, incoming reservations, idle vehicles, and upgrade candidates.               |
| Line editor           | Pick stops, interval, vehicles, and empty-departure policy. Preview the next departure.            |
| Results               | Explain delivery time, settlement, trip costs, unused capacity, and reputation changes.            |

Use tap or click to select a town, drag to pan, and pinch or wheel to zoom. Offer visible controls for critical actions,
keyboard-friendly desktop navigation, readable text, reduced motion, and an independent audio volume setting. Keep
player-facing strings localizable.

## 7. Simulation and persistence

- Use an integer simulation clock. Pause stops simulation time, including deadlines. The prototype clock also stops when
  the game closes. Handle events due at the same tick in stable order, with arrivals and unloading before new
  departures. A delivery completed on the deadline is on time.
- Each accepted order has one current location at any moment. Queue and vehicle capacity calculations include existing
  reservations. Validation occurs before a command mutates money, cargo, or reservations. A rejected command leaves
  state unchanged.
- Use authored catalogs for towns, vehicle definitions, freight classes, and contract templates. Store IDs and mutable
  company state in a versioned save snapshot, including route assignments, reservations, clock, settlement IDs,
  scheduled departures, and in-transit arrival times. Persist the local slot through `RD.Save` and restore in-flight
  jobs before resuming the clock. Save after material transactions and at controlled intervals.
- Compose startup and scene switching through `RD.Startup` and `RD.SceneFlow`, settings through `RD.Settings`, and reuse
  Foundation primitives where needed. The engine-independent simulation owns all logistics rules. The data and
  integration boundaries are defined in [AGENTS.md](../AGENTS.md).

## 8. Delivery plan and acceptance

| Phase                 | Scope                                                                                                                                 | Exit condition                                                                                                                                                    |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1. Playable dispatch  | Six towns, one depot, van and box truck definitions, dry cargo, map, contract board, manual dispatch, clock, and saved company state. | A new player accepts and dispatches a valid order, sees the financial result, and can close and resume an active run without losing or duplicating cargo or cash. |
| 2. Network management | Second depot, transfers, chilled cargo, reefer, backhauls, scheduled routes, and upgrades.                                            | One order transfers through a depot, automation respects dwell time and storage, and the player can compare loaded and empty return legs.                         |
| 3. Regional expansion | Regional unlocks, airport terminals, air freight, road-to-air transfers, and announced disruptions.                                   | Air freight is preferable on some trips, road on others, and an interrupted chain offers a workable recovery path.                                                |

Prototype playtests should verify that players complete a first delivery within five minutes, understand a blocked
dispatch without help, can compare the margin between two routes, and can identify a reason to open a second depot.
Balance vehicle and depot costs after those sessions. Multiplayer, live services, and monetization are outside the
prototype scope.