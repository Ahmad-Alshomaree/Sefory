# Product Requirements Document (PRD)
## Intercity Car Booking App — Iraq (MVP)

---

## 1. Overview

A mobile marketplace app that connects passengers in Iraq with independent car owners (drivers) for intercity trips. Passengers browse available drivers filtered by route, request a trip, and the driver accepts or declines directly through the app. Payment happens offline between passenger and driver; the platform logs trip value for later commission reconciliation.

**Platform:** Mobile app (Flutter — iOS & Android from one codebase)
**Backend:** Node.js (Express)
**Database:** PostgreSQL
**Notifications:** Firebase Cloud Messaging (push notifications)

---

## 2. User Roles

1. **Passenger** — books trips, either as an individual or on behalf of a family.
2. **Driver (Car Owner)** — registers a car, sets allowed cities, accepts/declines trip requests.
3. **Admin (Platform Owner)** — views trip logs, driver cancellation history, and manages verification (backend/admin panel, not in mobile MVP scope but needs DB support).

---

## 3. Core Features

### 3.1 Passenger Flow
- Sign up / log in (phone number based).
- Select trip type: **Family** or **Individual**.
- Select **departure city** and **destination city**.
- App filters and shows only drivers whose allowed-city list covers that route.
- Browse filtered driver/car list: car model, car name, price, driver name/rating (future).
- Select a car.
- Enter **exact pickup location** and **exact drop-off location** as **Google Maps links** (not free text).
- Submit trip request (no chat/messaging involved).
- Receive push notification when driver accepts or declines.
- View **trip history** (past trips: driver, route, date, price) to easily rebook a trusted driver.

### 3.2 Driver Flow
- Sign up / log in with:
  - Full name, surname
  - Phone number
  - Driver's license (photo/number)
  - Car details (model, year, color, plate number, photo)
- Select **list of allowed cities** the driver is willing to travel to/from (not open to all of Iraq by default).
- Receive push notification when a passenger requests their car.
- View request details: trip type (family/individual), pickup link, drop-off link.
- **Accept** or **Decline** the request.
- On acceptance: enter/confirm the **trip price**.
- Mark trip status: **Started** → **Completed**.
- View own **trip history**.

### 3.3 Trip Lifecycle / Anti-Cancellation Safeguard
Trip statuses: `requested` → `accepted` → `started` → `completed` (or `declined` / `cancelled`).

- Driver must mark **Started** once they pick up the passenger, and **Completed** once the trip ends.
- If a driver **accepts** a trip and then cancels, or fails to mark it started within a reasonable time window, this is logged as a **cancellation strike** against their profile.
- Accumulated strikes are visible to the admin for manual review/suspension in the MVP (automated suspension can come later).

### 3.4 Payments
- **No in-app payment processing.** Passenger pays driver directly (cash or however they arrange it).
- Driver enters the agreed trip price when accepting the request.
- This price is stored against the trip record for the platform owner to use in commission reconciliation with drivers (handled outside the app for MVP).

### 3.5 Trip History
- Passenger side: list of past trips with driver name, car, route (departure/destination city), date, price, status.
- Driver side: list of past trips with passenger info (minimal), route, date, price, status.

---

## 4. Suggested MVP Additions (for your consideration)

- **Driver verification badge**: a simple `verified` boolean/status so passengers can see a driver has been checked, not just self-registered.
- **Basic filtering/sorting** on the results list (by price, car type) once multiple drivers match a route.
- **Simple report/dispute flag**: passenger or driver can flag a trip if something went wrong; handled manually by admin at MVP stage.

---

## 5. Database Schema (PostgreSQL)

```sql
-- USERS (shared base table for passengers and drivers, or separate — using separate here for clarity)

CREATE TABLE passengers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(150) NOT NULL,
    surname VARCHAR(150) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    license_number VARCHAR(100) NOT NULL,
    license_photo_url TEXT,
    is_verified BOOLEAN DEFAULT false,
    cancellation_strikes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT now()
);

-- CARS (a driver could theoretically own more than one, so kept separate)

CREATE TABLE cars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    model VARCHAR(100) NOT NULL,
    name VARCHAR(100),           -- e.g. display name/nickname
    plate_number VARCHAR(20) NOT NULL,
    color VARCHAR(50),
    year INT,
    photo_url TEXT,
    price VARCHAR(50),           -- base/reference price shown in listings
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT now()
);

-- DRIVER ALLOWED CITIES (many-to-many: a driver can serve many cities)

CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE driver_cities (
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    city_id INT NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
    PRIMARY KEY (driver_id, city_id)
);

-- TRIPS

CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    passenger_id UUID NOT NULL REFERENCES passengers(id),
    driver_id UUID REFERENCES drivers(id),        -- null until a driver's car is chosen
    car_id UUID REFERENCES cars(id),
    trip_type VARCHAR(20) NOT NULL CHECK (trip_type IN ('family', 'individual')),
    departure_city_id INT NOT NULL REFERENCES cities(id),
    destination_city_id INT NOT NULL REFERENCES cities(id),
    pickup_map_link TEXT NOT NULL,
    dropoff_map_link TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'requested'
        CHECK (status IN ('requested', 'accepted', 'declined', 'started', 'completed', 'cancelled')),
    price NUMERIC(10,2),
    requested_at TIMESTAMP DEFAULT now(),
    accepted_at TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

-- CANCELLATION LOG (for tracking driver reliability)

CREATE TABLE driver_cancellations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    trip_id UUID NOT NULL REFERENCES trips(id),
    reason TEXT,
    created_at TIMESTAMP DEFAULT now()
);

-- NOTIFICATIONS (optional log table for push notification history)

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_type VARCHAR(20) NOT NULL CHECK (recipient_type IN ('passenger', 'driver')),
    recipient_id UUID NOT NULL,
    trip_id UUID REFERENCES trips(id),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT now()
);
```

### Relationship Summary
- One **driver** → many **cars**
- One **driver** → many **cities** (via `driver_cities`), and one **city** → many drivers
- One **passenger** → many **trips**
- One **driver** → many **trips**
- One **trip** → one **car**, one **departure city**, one **destination city**
- One **driver** → many **cancellation log entries**

---

## 6. Tech Stack Summary

| Layer | Choice |
|---|---|
| Mobile App | Flutter (Dart) |
| Backend API | Node.js + Express |
| Database | PostgreSQL |
| Push Notifications | Firebase Cloud Messaging |
| Auth | Phone number + password (JWT sessions) |
| Maps | Google Maps links (passenger-supplied, no in-app map SDK required for MVP) |

---

## 7. Implementation Phases

To make development easier, the PRD is split into phases. Phase 1 is the true MVP and should be built first. Later phases add trust, admin, and growth features without blocking the core booking flow.

### Phase 1 — Core MVP Booking Flow
Build the smallest end-to-end product that lets a passenger request a trip and a driver accept it.

#### Step-by-step checklist
1. Set up the shared user foundations for passengers and drivers, including authentication, profile fields, and database relationships.
2. Create the city data model and seed the initial Iraq city list.
3. Build passenger sign up and log in with phone number and password.
4. Build driver sign up and log in with required profile fields and car details.
5. Add driver allowed-cities selection so each driver can control where they operate.
6. Build passenger route search with departure city, destination city, and trip type.
7. Filter drivers and cars so passengers only see options that match the selected route.
8. Build the trip request form with pickup and drop-off Google Maps links.
9. Create the driver request inbox with accept and decline actions.
10. Save the agreed trip price when the driver accepts a request.
11. Implement the trip lifecycle statuses: requested, accepted, started, completed, declined, cancelled.
12. Add push notifications for trip request creation, acceptance, and decline events.
13. Build passenger and driver trip history screens with the core trip details.
14. Store trip price and trip status so offline payment reconciliation can happen later.
15. Add validation and edge-case handling for invalid routes, missing links, and duplicate requests.

#### Phase 1 definition of done
- A passenger can register, log in, search a route, request a trip, and see the trip status update.
- A driver can register, log in, receive the request, accept or decline it, set the price, and mark the trip as started and completed.
- Trip history is visible on both sides.
- No payment processing, ratings, dispute system, or admin dashboard is required yet.

Do not include in Phase 1:
- Ratings.
- Dispute reporting.
- Automated suspension.
- Admin dashboard UI.
- Advanced sorting/filtering.

### Phase 2 — Trust And Admin Support
Add the operational features needed to monitor reliability and manually review drivers.

#### Step-by-step checklist
1. Add a verified status or badge to the driver profile so trusted drivers can be identified.
2. Track driver cancellation strikes when a driver cancels after accepting or fails to start a trip in time.
3. Store cancellation records in the database with a clear link to the driver and trip.
4. Add admin-facing data access for viewing trips, driver profiles, and cancellation history.
5. Support manual review and suspension workflows in the backend data model.
6. Add a simple trip report or dispute flag so passengers and drivers can escalate problems.
7. Add basic sorting and filtering on the passenger results list.
8. Expose the minimum backend endpoints or admin queries needed to support internal review.

#### Phase 2 definition of done
- Admin can inspect driver reliability and trip history.
- Driver verification and cancellation strike data are stored and visible.
- A trip can be flagged for manual review.
- The passenger search results can be sorted or filtered in a basic way.

### Phase 3 — Growth And Refinement
Add features that improve conversion, retention, and operational efficiency after the MVP is stable.

#### Step-by-step checklist
1. Add passenger driver ratings after trips are completed.
2. Add rebooking shortcuts so passengers can quickly book a trusted driver again.
3. Build richer reconciliation views for the platform owner to review completed trips and prices.
4. Add operational dashboards for analytics, usage trends, and driver performance.
5. Introduce automated rules for repeated cancellations if manual review is no longer enough.
6. Improve search and trip discovery with better ranking, filtering, or saved preferences.

#### Phase 3 definition of done
- Passengers can rate drivers after completed trips.
- Rebooking a prior driver is faster than creating a new trip from scratch.
- The platform owner can review growth and operational metrics.
- Automated reliability rules can be added without changing the Phase 1 booking flow.

---

## 8. Google Stitch Design Prompt

Copy the prompt below into Google Stitch to generate the UI design:

> Design a clean, modern mobile app UI (for both iOS and Android) for an intercity car booking app used in Iraq, called for a marketplace connecting passengers with independent car owners for trips between cities. Support Arabic (RTL) and English.
>
> Screens needed:
> 1. Onboarding / phone number login and signup, with a toggle between "Passenger" and "Driver" account types.
> 2. Passenger home screen: a search bar to select departure city and destination city, and a toggle for "Family" or "Individual" trip type.
> 3. Search results screen: a scrollable list of available cars/drivers matching the selected route, each card showing car photo, car model/name, price, and driver name.
> 4. Trip request screen: fields to paste/select a Google Maps pickup link and drop-off link, with a prominent "Request Trip" button.
> 5. Trip status screen: shows current trip status (requested, accepted, started, completed) with a simple progress indicator, and the assigned driver's info.
> 6. Trip history screen: a list of past trips for the passenger, each showing driver name, route, date, and price, with a "Book Again" button.
> 7. Driver home screen: incoming trip request cards with accept/decline buttons, and a toggle to go online/offline.
> 8. Driver trip detail screen: shows pickup/drop-off map links, trip type, a field to enter/confirm price, and buttons to mark "Trip Started" and "Trip Completed."
> 9. Driver profile/settings screen: license info, car details, and a multi-select list of allowed cities.
>
> Style: friendly, trustworthy, modern — use a warm but professional color palette (avoid generic ride-hailing black/yellow), rounded cards, clear typography, and simple iconography suited to a general Iraqi audience across age groups.

---

*This document is intended to be handed to a code generation tool to scaffold the Flutter frontend and Node.js/PostgreSQL backend.*
